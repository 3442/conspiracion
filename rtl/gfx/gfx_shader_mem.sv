module gfx_shader_mem
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  mem_op            op,
	input  wave_exec         wave,

	       gfx_regfile_io.ab read_data,

	       if_shake.rx       in_shake,

	       if_axib.m         mem,

	       gfx_wb.tx         wb
);

	if_beats #($bits(group_id)) aw_pending(), b_return();
	if_beats #($bits(group_id) + $bits(vgpr_num)) ar_pending(), r_return();

	logic ar_load, aw_load, b_queued, r_done, r_writeback,
	      w_load, w_shift, w_start, w_strobe;

	group_id b_return_group, r_return_group;
	vgpr_num r_return_vgpr;
	logic[$bits(group_id):0] b_add, b_count;

	assign mem.wstrb = {($bits(mem.wstrb)){w_strobe}};
	assign mem.bready = 1;
	assign mem.rready = ~r_writeback | r_done;

	assign wb.mask = 'x;
	assign wb.group = r_writeback ? r_return_group : b_return_group;
	assign wb.valid = r_writeback ? r_return.rx.valid : b_return.rx.valid & b_queued;
	assign wb.pc_add = 'x;
	assign wb.pc_inc = 1;
	assign wb.scalar = 0;
	assign wb.dest.vgpr = r_return_vgpr;
	assign wb.pc_update = 1;
	assign wb.writeback = r_writeback;
	assign wb.mask_update = 0;

	assign w_load = ~mem.wvalid | (mem.wlast & mem.wready);
	assign w_shift = mem.wvalid & mem.wready;
	assign w_start = in_shake.valid & ~op.load & aw_load & w_load;

	assign r_done = wb.ready & r_writeback & r_return.rx.valid;
	assign b_queued = |b_count;
	assign b_return_group = b_return.rx.data;
	assign {r_return_group, r_return_vgpr} = r_return.rx.data;

	assign in_shake.ready = op.load ? ar_load : aw_load & w_load;
	assign b_return.rx.ready = wb.ready & ~r_writeback & b_queued;
	assign r_return.rx.ready = wb.ready & r_writeback;
	assign ar_pending.tx.data = {wave.group, wave.dest.vgpr};
	assign aw_pending.tx.data = wave.group;
	assign ar_pending.tx.valid = in_shake.valid & op.load & ar_load;
	assign aw_pending.tx.valid = w_start;

	gfx_shader_mem_addr_channel ar_channel
	(
		.clk,
		.rst_n,

		.load(ar_load),
		.load_mask(read_data.mask_exec),
		.load_lanes(read_data.a),
		.load_valid(in_shake.valid & op.load),

		.axid(mem.arid),
		.axlen(mem.arlen),
		.axaddr(mem.araddr),
		.axsize(mem.arsize),
		.axburst(mem.arburst),
		.axready(mem.arready),
		.axvalid(mem.arvalid)
	);

	gfx_shader_mem_addr_channel aw_channel
	(
		.clk,
		.rst_n,

		.load(aw_load),
		.load_mask(read_data.mask_exec),
		.load_lanes(read_data.a),
		.load_valid(in_shake.valid & ~op.load & w_load),

		.axid(mem.awid),
		.axlen(mem.awlen),
		.axaddr(mem.awaddr),
		.axsize(mem.awsize),
		.axburst(mem.awburst),
		.axready(mem.awready),
		.axvalid(mem.awvalid)
	);

	gfx_shader_mem_piso_shift w_stream
	(
		.clk,
		.load(w_load),
		.shift(w_shift),
		.in_mask(read_data.mask_exec),
		.in_lanes(read_data.b),
		.out_data(mem.wdata),
		.out_last(mem.wlast),
		.out_enable(w_strobe)
	);

	gfx_shader_mem_sipo_shift r_stream
	(
		.clk,
		.rst_n,
		.shift(mem.rready & mem.rvalid),
		.in_data(mem.rdata),
		.in_done(r_done),
		.in_last(mem.rlast),
		.out_lanes(wb.lanes),
		.out_valid(r_writeback)
	);


	gfx_fifo #(.WIDTH($bits(group_id) + $bits(vgpr_num)), .DEPTH(1 << $bits(group_id))) ar_to_r
	(
		.clk,
		.rst_n,
		.in(ar_pending.rx),
		.out(r_return.tx)
	);

	gfx_fifo #(.WIDTH($bits(group_id)), .DEPTH(1 << $bits(group_id))) aw_to_b
	(
		.clk,
		.rst_n,
		.in(aw_pending.rx),
		.out(b_return.tx)
	);

	always_comb
		unique case ({mem.bvalid, b_return.rx.ready & b_return.rx.valid})
			2'b00, 2'b11:
				b_add = '0;

			2'b01:
				b_add = '1;

			2'b10:
				b_add = {{($bits(b_add) - 1){1'b0}}, 1'b1};
		endcase

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			b_count <= '0;
			mem.wvalid <= 0;
		end else begin
			b_count <= b_count + b_add;
			mem.wvalid <= w_start | (mem.wvalid & ~(mem.wlast & mem.wready));

			assert (ar_pending.tx.ready);
			assert (aw_pending.tx.ready);
		end

endmodule

module gfx_shader_mem_addr_channel
import gfx::*;
(
	input  logic      clk,
	                  rst_n,

	input  word       load_lanes[SHADER_LANES],
	input  lane_mask  load_mask,
	input  logic      load_valid,
	output logic      load,

	input  logic      axready,
	output logic      axvalid,
	output word       axaddr,
	output logic[7:0] axid,
	                  axlen,
	output logic[2:0] axsize,
	output logic[1:0] axburst
);

	logic active, shift, strobe;

	assign axid = '0;
	assign axlen = ($bits(axlen))'(SHADER_LANES - 1);
	assign axsize = 3'b010; // 4 bytes/beat
	assign axburst = 2'b01; // Incremental mode
	assign axvalid = active & strobe;

	assign load = ~active | (strobe & axready);
	assign shift = active & ~strobe;

	gfx_shader_mem_piso_shift ax_stream
	(
		.clk,
		.load,
		.shift,
		.in_mask(load_mask),
		.in_lanes(load_lanes),
		.out_data(axaddr),
		.out_last(),
		.out_enable(strobe)
	);

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			active <= 0;
		else
			active <= ~load | load_valid;

endmodule

module gfx_shader_mem_piso_shift
import gfx::*;
(
	input  logic     clk,

	input  logic     load,
	                 shift,

	input  word      in_lanes[SHADER_LANES],
	input  lane_mask in_mask,

	output word      out_data,
	output logic     out_last,
	                 out_enable
);

	word data[SHADER_LANES];
	lane_no count;
	lane_mask mask;

	assign out_data = data[0];
	assign out_last = &count;
	assign out_enable = mask[0];

	always_ff @(posedge clk)
		if (load) begin
			data <= in_lanes;
			mask <= in_mask;
			count <= '0;
		end else if (shift) begin
			for (int i = 0; i < SHADER_LANES - 1; ++i)
				data[i] <= data[i + 1];

			mask <= mask >> 1;
			count <= count + 1;
		end

endmodule

module gfx_shader_mem_sipo_shift
import gfx::*;
(
	input  logic clk,
	             rst_n,

	input  logic shift,
	             in_done,
	             in_last,
	input  word  in_data,

	output word  out_lanes[SHADER_LANES],
	output logic out_valid
);

	always_ff @(posedge clk)
		if (shift) begin
			for (int i = 0; i < SHADER_LANES - 1; ++i)
				out_lanes[i] <= out_lanes[i + 1];

			out_lanes[SHADER_LANES - 1] <= in_data;
		end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			out_valid <= 0;
		else if (in_done)
			out_valid <= 0;
		else if (shift)
			out_valid <= in_last;

endmodule
