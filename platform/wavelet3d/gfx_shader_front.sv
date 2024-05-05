typedef struct
{
	logic              valid,
	                   retry;
	gfx::group_id      group;
	gfx_isa::insn_word insn;
} front_wave;

typedef struct
{
	gfx::xgpr_num dest;
	logic         dest_scalar;
} front_reg_passthru;

typedef logic[4:0] icache_line_num;

typedef logic[$bits(gfx::oword_ptr) - $bits(icache_line_num) - 1:0] icache_tag;

typedef struct packed
{
	icache_tag      tag;
	icache_line_num line;
} icache_line_tag;

typedef struct packed
{
	icache_line_tag line_tag;
	logic[2:0]      word_num;
} icache_ptr;

module gfx_shader_front
import gfx::*;
(
	input  logic                clk,
	                            rst_n,

	       gfx_axib.m           fetch_mem,

	input  logic                icache_flush,

	       gfx_regfile_io.read  reg_read,
	       gfx_regfile_io.bind_ reg_bind,

	       gfx_front_back.front front
);

	word fetch_insn, port_insn;
	logic fetch_hit, p0_writeback;
	front_wave bind_wave, dec_wave, port_dec_wave;
	front_reg_passthru reg_passthru;

	assign front.execute.wave.dest = reg_passthru.dest;
	assign front.execute.wave.dest_scalar = reg_passthru.dest_scalar;

	gfx_shader_bind bind_
	(
		.clk,
		.rst_n,
		.mem(fetch_mem),
		.wave(bind_wave),
		.regs(reg_bind),
		.loop_valid(front.loop.valid),
		.loop_group(front.loop.group),
		.icache_flush
	);

	gfx_shader_read_regs reg_dec
	(
		.clk,
		.rst_n,
		.in(bind_wave),
		.out(dec_wave),
		.read(reg_read),
		.passthru(reg_passthru)
	);

	gfx_shader_decode_class class_dec
	(
		.clk,
		.rst_n,
		.wave(dec_wave),
		.out_group(front.execute.wave.group),
		.port_wave(port_dec_wave),
		.dispatch(front.dispatch),
		.p0_writeback
	);

	gfx_shader_decode_fpint p0_dec
	(
		.clk,
		.op(front.execute.p0),
		.insn(port_dec_wave.insn),
		.writeback(p0_writeback)
	);

endmodule

module gfx_shader_bind
import gfx::*;
(
	input  logic                clk,
	                            rst_n,

	       gfx_axib.m           mem,

	input  logic                icache_flush,

	input  logic                loop_valid,
	input  group_id             loop_group,

	       gfx_regfile_io.bind_ regs,

	output front_wave           wave
);

	localparam int ICACHE_STAGES = 6;
	localparam int BIND_STAGES = REGFILE_STAGES + ICACHE_STAGES;

	gfx_beats #($bits(group_id)) runnable_in(), runnable_out();

	logic ar_stall, request_ready, request_valid, valids[BIND_STAGES];
	group_id groups[BIND_STAGES];
	icache_line_tag araddr, request_addr;

	assign mem.bready = 0;
	assign mem.wvalid = 0;
	assign mem.awvalid = 0;

	assign mem.arlen = ($bits(mem.arlen))'($bits(oword) / $bits(word) - 1);
	assign mem.araddr = {araddr, ($clog2($bits(oword)) - $clog2($bits(word)) + SUBWORD_BITS)'('0)};
	assign mem.arburst = 2'b01; // Incremental mode

	assign runnable_in.tx.data = loop_group;
	assign runnable_in.tx.valid = loop_valid;

	assign regs.pc_front_group = runnable_out.rx.data;
	assign runnable_out.rx.ready = 1;

	assign wave.group = groups[$size(groups) - 1];

	gfx_skid_buf #($bits(araddr)) ar_skid
	(
		.clk,
		.in(request_addr),
		.out(araddr),
		.stall(ar_stall)
	);

	gfx_skid_flow ar_flow
	(
		.clk,
		.rst_n,
		.stall(ar_stall),
		.in_ready(request_ready),
		.in_valid(request_valid),
		.out_ready(mem.arready),
		.out_valid(mem.arvalid)
	);

	//TODO: Podríamos quitar ~25 entries sin afectar throughput, latencia o correctitud
	gfx_fifo #(.WIDTH($bits(group_id)), .DEPTH(1 << $bits(group_id))) runnable
	(
		.clk,
		.rst_n,
		.in(runnable_in.rx),
		.out(runnable_out.tx)
	);

	gfx_shader_bind_icache icache
	(
		.clk,
		.rst_n,

		.icache_flush,
		.read_addr(regs.pc_front),
		.read_valid(valids[REGFILE_STAGES - 1]),

		.request_addr,
		.request_valid,
		.request_ready,

		.fetch_data(mem.rdata),
		.fetch_last(mem.rlast),
		.fetch_valid(mem.rvalid),
		.fetch_ready(mem.rready),

		.insn(wave.insn),
		.insn_retry(wave.retry),
		.insn_valid(wave.valid)
	);

	always_ff @(posedge clk) begin
		groups[0] <= runnable_out.rx.data;
		for (int i = 1; i < $size(groups); ++i)
			groups[i] <= groups[i - 1];
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			for (int i = 0; i < $size(valids); ++i)
				valids[i] <= 0;
		else begin
			valids[0] <= runnable_out.rx.valid;
			for (int i = 1; i < $size(valids); ++i)
				valids[i] <= valids[i - 1];
		end

endmodule

module gfx_shader_bind_icache
import gfx::*;
(
	input  logic           clk,
	                       rst_n,

	input  logic           icache_flush,

	input  logic           read_valid,
	input  icache_ptr      read_addr,

	input  logic           fetch_last,
	                       fetch_valid,
	input  word            fetch_data,
	output logic           fetch_ready,

	input  logic           request_ready,
	output logic           request_valid,
	output icache_line_tag request_addr,

	output logic           insn_valid,
	                       insn_retry,
	output word            insn
);

	// Dan Gisselquist limita a (1 << 3) bursts por defecto.
	// Ver LGMAXBURST en axixbar.v
	localparam int PENDING_FIFO_DEPTH = 8;

	enum int unsigned
	{
		FLUSH,
		RUN
	} state;

	struct
	{
		logic      valid,
		           accessed,
		           hit;
		icache_tag tag;
		oword      data;
	} cache[1 << $bits(icache_line_num)], read, read_hold;

	gfx_beats #($bits(icache_line_tag)) pending_in(), pending_out();

	logic accessed_write, accessed_write_enable, burst, fetch_done, hit_write,
	      in_flush, hit_commit, hit_write_enable, retry_4, retry_5, rollback,
	      tag_hit, valid_1, valid_2, valid_3, valid_4, valid_5, valid_write,
	      valid_write_enable;

	icache_ptr read_addr_1, read_addr_2, read_addr_3, read_addr_4, read_addr_5;
	icache_tag tag_write;
	icache_line_num accessed_write_line, flush_ptr, hit_write_line, valid_write_line;
	icache_line_tag pending_pop;

	oword data_write;
	word[1:0] data_5;
	word[7:0] fetch_shift;
	qword[1:0] data_3;
	udword[1:0] data_4;

	assign data_3 = read.data;
	assign tag_hit = read.tag == read_addr_3.line_tag.tag;
	assign fetch_ready = ~fetch_done;
	assign pending_pop = pending_out.rx.data;

	assign request_addr = read_addr_4.line_tag;
	assign request_valid = burst & pending_in.tx.ready;
	assign pending_in.tx.data = read_addr_4.line_tag;
	assign pending_in.tx.valid = burst & request_ready;
	assign pending_out.rx.ready = fetch_done & ~hit_commit & ~rollback;

	gfx_fifo #(.WIDTH($bits(icache_line_tag)), .DEPTH(PENDING_FIFO_DEPTH)) pending
	(
		.clk,
		.rst_n,
		.in(pending_in.rx),
		.out(pending_out.tx)
	);

	always_comb
		unique case (state)
			FLUSH: in_flush = 1;
			RUN:   in_flush = 0;
		endcase

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			state <= FLUSH;
			flush_ptr <= '0;
			fetch_done <= 0;

			valid_1 <= 0;
			valid_2 <= 0;
			valid_3 <= 0;
			valid_4 <= 0;
			valid_5 <= 0;

			burst <= 0;
		end else begin
			unique case (state)
				FLUSH:
					if (~icache_flush & &flush_ptr)
						state <= RUN;

				RUN:
					if (icache_flush)
						state <= FLUSH;
			endcase

			flush_ptr <= flush_ptr + 1;
			if (icache_flush)
				flush_ptr <= '0;

			if (fetch_done)
				fetch_done <= hit_commit | ~pending_out.rx.valid | rollback;
			else if (fetch_ready & fetch_valid)
				fetch_done <= fetch_last;

			valid_1 <= read_valid;
			valid_2 <= valid_1;
			valid_3 <= valid_2;
			valid_4 <= valid_3;
			valid_5 <= valid_4;

			burst <= valid_3 & ~tag_hit & ~read.accessed & (~read.valid | read.hit);
		end

	always_ff @(posedge clk) begin
		tag_write <= pending_pop.tag;
		data_write <= fetch_shift;

		valid_write <= 1;
		valid_write_line <= pending_pop.line;
		valid_write_enable <= fetch_done & ~hit_commit & pending_out.rx.valid & ~rollback;

		accessed_write <= 0;
		accessed_write_enable <= 1;

		if (rollback)
			accessed_write_line <= read_addr_5.line_tag.line;
		else if (fetch_done & ~hit_commit & pending_out.rx.valid)
			accessed_write_line <= pending_pop.line;
		else begin
			accessed_write <= 1;
			accessed_write_line <= read_addr.line_tag.line;
			accessed_write_enable <= read_valid;
		end

		hit_write <= hit_commit;
		if (hit_commit) begin
			hit_write_line <= read_addr_4.line_tag.line;
			hit_write_enable <= 1;
		end else begin
			hit_write_line <= pending_pop.line;
			hit_write_enable <= fetch_done & pending_out.rx.valid & ~rollback;
		end

		if (in_flush) begin
			valid_write <= 0;
			valid_write_line <= flush_ptr;
			valid_write_enable <= 1;

			accessed_write <= 0;
			accessed_write_line <= flush_ptr;
			accessed_write_enable <= 1;

			hit_write <= 0;
			hit_write_line <= flush_ptr;
			hit_write_enable <= 1;
		end

		if (valid_write_enable) begin
			cache[valid_write_line].tag <= tag_write;
			cache[valid_write_line].data <= data_write;
			cache[valid_write_line].valid <= valid_write;
		end

		if (accessed_write_enable)
			cache[accessed_write_line].accessed <= accessed_write;

		if (hit_write_enable)
			cache[hit_write_line].hit <= hit_write;

		read_addr_1 <= read_addr;

		read_hold <= cache[read_addr_1.line_tag.line];
		read_addr_2 <= read_addr_1;

		read <= read_hold;
		read_addr_3 <= read_addr_2;

		data_4 <= data_3[read_addr_3.word_num[2]];
		retry_4 <= ~tag_hit | ~read.valid;
		hit_commit <= valid_3 & tag_hit & read.valid;
		read_addr_4 <= read_addr_3;

		data_5 <= data_4[read_addr_4.word_num[1]];
		retry_5 <= retry_4;
		rollback <= burst & (~request_valid | ~pending_in.tx.valid);
		read_addr_5 <= read_addr_4;

		insn <= data_5[read_addr_5.word_num[0]];
		insn_retry <= retry_5;
		insn_valid <= valid_5;

		if (fetch_ready & fetch_valid) begin
			fetch_shift[0] <= fetch_data;
			for (int i = 1; i < $size(fetch_shift); ++i)
				fetch_shift[i] <= fetch_shift[i - 1];
		end
	end

endmodule

module gfx_shader_read_regs
import gfx::*;
import gfx_isa::*;
(
	input  logic               clk,
	                           rst_n,

	input  front_wave          in,

	       gfx_regfile_io.read read,

	output front_wave          out,
	output front_reg_passthru  passthru
);

	// + 1 por next-cycle de read.op
	localparam int PASSTHRU_DEPTH = REG_READ_STAGES + 1 - 2;
	localparam int HOLD_DEPTH     = PASSTHRU_DEPTH - 2;

	logic reg_rev;
	logic valid[HOLD_DEPTH];
	front_wave out_hold[HOLD_DEPTH];
	front_reg_passthru passthru_hold[PASSTHRU_DEPTH];

	assign passthru = passthru_hold[$size(passthru_hold) - 1];

	assign reg_rev = in.insn.reg_rev;

	always_comb begin
		out = out_hold[$size(out_hold) - 1];
		out.valid = valid[$size(valid) - 1];
	end

	always_ff @(posedge clk) begin
		out_hold[0] <= in;
		for (int i = 1; i < $size(out_hold); ++i)
			out_hold[i] <= out_hold[i - 1];

		passthru_hold[0].dest <= in.insn.dst_src.rr.rd;
		unique case (in.insn.reg_mode)
			REGS_SVS, REGS_SSS:
				passthru_hold[0].dest_scalar <= 1;

			REGS_VVS, REGS_VVV:
				passthru_hold[0].dest_scalar <= 0;
		endcase

		for (int i = 1; i < $size(passthru_hold); ++i)
			passthru_hold[i] <= passthru_hold[i - 1];

		read.op.group <= in.group;

		read.op.b_imm <= in.insn.dst_src.rr.b.imm;
		read.op.a_sgpr <= in.insn.dst_src.rr.ra.sgpr;
		read.op.b_sgpr <= in.insn.dst_src.rr.b.read.r.sgpr;
		read.op.a_vgpr <= in.insn.dst_src.rr.ra.vgpr.num;
		read.op.b_vgpr <= in.insn.dst_src.rr.b.read.r.vgpr.num;
		read.op.b_is_imm <= in.insn.dst_src.rr.b_is_imm;
		read.op.b_is_const <= in.insn.dst_src.rr.b.read.from_consts;
		read.op.scalar_rev <= reg_rev;

		unique case (in.insn.reg_mode)
			REGS_SVS, REGS_VVS: begin
				read.op.a_scalar <= reg_rev;
				read.op.b_scalar <= ~reg_rev;
			end

			REGS_SSS: begin
				read.op.a_scalar <= 1;
				read.op.b_scalar <= 1;
			end

			REGS_VVV: begin
				read.op.a_scalar <= 0;
				read.op.b_scalar <= 0;
			end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			for (int i = 0; i < HOLD_DEPTH; ++i)
				valid[i] <= 0;
		else begin
			valid[0] <= in.valid;

			for (int i = 1; i < HOLD_DEPTH; ++i)
				valid[i] <= valid[i - 1];
		end

endmodule

module gfx_shader_decode_class
import gfx::*;
import gfx_isa::*;
(
	input  logic           clk,
	                       rst_n,

	input  front_wave      wave,
	output front_wave      port_wave,
	output group_id        out_group,

	output shader_dispatch dispatch,
	output logic           p0_writeback
);

	logic is_fsu, is_mem, is_group, hold_valid, retry;
	front_wave hold_wave;

	assign p0_writeback = ~(is_mem | is_fsu | is_group | retry);

	always_comb begin
		port_wave = hold_wave;
		port_wave.valid = hold_valid;
	end

	always_ff @(posedge clk) begin
		hold_wave <= wave;
		out_group <= port_wave.group;
	end

	always_ff @(posedge clk or negedge rst_n)
		// Intencionalmente repetitivo
		if (~rst_n) begin
			is_fsu <= 0;
			is_mem <= 0;
			is_group <= 0;

			retry <= 0;
			hold_valid <= 0;

			dispatch <= '0;
		end else begin
			is_fsu <= 0;
			is_mem <= 0;
			is_group <= 0;

			retry <= wave.retry;
			hold_valid <= wave.valid;

			unique case (wave.insn.insn_class)
				INSN_FPINT: ; // p0 no tiene ready
				INSN_MEM:   is_mem   <= 1;
				INSN_SFU:   is_fsu   <= 1;
				INSN_GROUP: is_group <= 1;

				default:
					{is_mem, is_fsu, is_group} <= 'x;
			endcase

			dispatch.p1 <= is_mem;
			dispatch.p2 <= is_fsu;
			dispatch.p3 <= is_group;

			if (~hold_valid | retry) begin
				dispatch.p1 <= 0;
				dispatch.p2 <= 0;
				dispatch.p3 <= 0;
			end

			dispatch.valid <= hold_valid;
		end

endmodule

module gfx_shader_decode_fpint
import gfx::*;
import gfx_isa::*;
(
	input  logic     clk,

	input  insn_word insn,
	input  logic     writeback,

	output fpint_op  op
);

	always_ff @(posedge clk) begin
		unique case (insn.by_class.fpint.op)
			INSN_FPINT_MOV: begin
				op.setup_mul_float    <= 0;
				op.setup_unit_b       <= 1;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 1;
				op.mnorm_put_mul      <= 0;
				op.mnorm_zero_flags   <= 1;
				op.mnorm_zero_b       <= 1;
				op.minmax_abs         <= 1;
				op.minmax_swap        <= 0;
				op.minmax_zero_min    <= 0;
				op.minmax_copy_flags  <= 1;
				op.shiftr_int_signed  <= 0;
				op.addsub_int_operand <= 0;
				op.addsub_copy_flags  <= 1;
				op.clz_force_nop      <= 1;
				op.shiftl_copy_flags  <= 1;
				op.round_copy_flags   <= 1;
				op.round_enable       <= 1;
				op.encode_enable      <= 1;
			end

			INSN_FPINT_FMUL: begin
				op.setup_mul_float    <= 1;
				op.setup_unit_b       <= 0;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 0;
				op.mnorm_put_mul      <= 1;
				op.mnorm_zero_flags   <= 0;
				op.mnorm_zero_b       <= 1;
				op.minmax_abs         <= 1;
				op.minmax_swap        <= 0;
				op.minmax_zero_min    <= 0;
				op.minmax_copy_flags  <= 1;
				op.shiftr_int_signed  <= 0;
				op.addsub_int_operand <= 0;
				op.addsub_copy_flags  <= 1;
				op.clz_force_nop      <= 1;
				op.shiftl_copy_flags  <= 1;
				op.round_copy_flags   <= 1;
				op.round_enable       <= 1;
				op.encode_enable      <= 1;
			end

			INSN_FPINT_IMUL: begin
				op.setup_mul_float    <= 0;
				op.setup_unit_b       <= 0;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 1;
				op.mnorm_put_mul      <= 0;
				op.mnorm_zero_flags   <= 1;
				op.mnorm_zero_b       <= 1;
				op.minmax_abs         <= 1;
				op.minmax_swap        <= 0;
				op.minmax_zero_min    <= 0;
				op.minmax_copy_flags  <= 1;
				op.shiftr_int_signed  <= 0;
				op.addsub_int_operand <= 0;
				op.addsub_copy_flags  <= 1;
				op.clz_force_nop      <= 1;
				op.shiftl_copy_flags  <= 1;
				op.round_copy_flags   <= 1;
				op.round_enable       <= 0;
				op.encode_enable      <= 0;
			end

			INSN_FPINT_FADD: begin
				op.setup_mul_float    <= 0;
				op.setup_unit_b       <= 1;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 1;
				op.mnorm_put_mul      <= 0;
				op.mnorm_zero_flags   <= 0;
				op.mnorm_zero_b       <= 0;
				op.minmax_abs         <= 1;
				op.minmax_swap        <= 0;
				op.minmax_zero_min    <= 0;
				op.minmax_copy_flags  <= 0;
				op.shiftr_int_signed  <= 0;
				op.addsub_int_operand <= 0;
				op.addsub_copy_flags  <= 0;
				op.clz_force_nop      <= 0;
				op.shiftl_copy_flags  <= 0;
				op.round_copy_flags   <= 0;
				op.round_enable       <= 1;
				op.encode_enable      <= 1;
			end

			INSN_FPINT_FMAX, INSN_FPINT_FMIN: begin
				op.setup_mul_float    <= 0;
				op.setup_unit_b       <= 1;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 1;
				op.mnorm_put_mul      <= 0;
				op.mnorm_zero_flags   <= 0;
				op.mnorm_zero_b       <= 0;
				op.minmax_abs         <= 0;
				op.minmax_swap        <= insn.by_class.fpint.op == INSN_FPINT_FMIN;
				op.minmax_zero_min    <= 1;
				op.minmax_copy_flags  <= 1;
				op.shiftr_int_signed  <= 0;
				op.addsub_int_operand <= 0;
				op.addsub_copy_flags  <= 1;
				op.clz_force_nop      <= 1;
				op.shiftl_copy_flags  <= 1;
				op.round_copy_flags   <= 1;
				op.round_enable       <= 0;
				op.encode_enable      <= 0;
			end

			INSN_FPINT_FCVT: begin
				op.setup_mul_float    <= 0;
				op.setup_unit_b       <= 1;
				op.mnorm_put_hi       <= 0;
				op.mnorm_put_lo       <= 1;
				op.mnorm_put_mul      <= 0;
				op.mnorm_zero_flags   <= 1;
				op.mnorm_zero_b       <= 1;

				op.minmax_abs         <= 1;
				op.minmax_swap        <= 0;
				op.minmax_zero_min    <= 0;
				op.minmax_copy_flags  <= 0;
				op.shiftr_int_signed  <= 1;
				op.addsub_int_operand <= 1;
				op.addsub_copy_flags  <= 1;
				op.clz_force_nop      <= 0;
				op.shiftl_copy_flags  <= 0;
				op.round_copy_flags   <= 0;
				op.round_enable       <= 1;
				op.encode_enable      <= 1;
			end

			default:
				op <= 'x;
		endcase

		op.writeback <= writeback;
	end

endmodule
