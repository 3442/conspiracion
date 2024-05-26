module gfx_shader_back
import gfx::*;
(
	input  logic                 clk,
	                             rst_n,

	       gfx_front_back.back   back,

	       gfx_regfile_io.ab     read_data,
	       gfx_regfile_io.wb     reg_wb,

	       gfx_shader_setup.core setup,

	       if_axib.m             data_mem
);

	logic abort;

	gfx_wb out_wb(), p0_wb(), p1_wb(), p2_wb(), p3_wb();
	if_shake p1_shake(), p2_shake(), p3_shake();

	gfx_shader_abort p0_abort
	(
		.clk,
		.p1(p1_shake.peek),
		.p2(p2_shake.peek),
		.p3(p3_shake.peek),
		.abort
	);

	gfx_shader_fpint p0
	(
		.clk,
		.rst_n,
		.op(back.execute.p0),
		.wb(p0_wb.tx),
		.wave(back.execute.wave),
		.abort,
		.read_data,
		.in_valid(back.dispatch.valid)
	);

	gfx_shader_mem p1
	(
		.clk,
		.rst_n,
		.op(back.execute.p1),
		.wb(p1_wb.tx),
		.mem(data_mem),
		.wave(back.execute.wave),
		.in_shake(p1_shake.rx),
		.read_data
	);

	gfx_shader_sfu p2
	(
		.clk,
		.rst_n,
		.op(back.execute.p2),
		.wb(p2_wb.tx),
		.wave(back.execute.wave),
		.in_shake(p2_shake.rx),
		.read_data
	);

	gfx_shader_group p3
	(
		.clk,
		.rst_n,
		.op(back.execute.p3),
		.wb(p3_wb.tx),
		.wave(back.execute.wave),
		.in_shake(p3_shake.rx),
		.read_data
	);

	gfx_shader_writeback_arbiter4 writeback_arbiter
	(
		.clk,
		.rst_n,
		.p0(p0_wb.rx),
		.p1(p1_wb.rx),
		.p2(p2_wb.rx),
		.p3(p3_wb.rx),
		.out(out_wb.tx)
	);

	gfx_shader_writeback writeback
	(
		.clk,
		.rst_n,
		.wb(out_wb.rx),
		.regs(reg_wb),
		.setup,
		.loop_group(back.loop.group),
		.loop_valid(back.loop.valid)
	);

endmodule

module gfx_shader_abort
(
	input  logic         clk,

	       if_shake.peek p1,
	                     p2,
	                     p3,

	output logic         abort
);

	always_ff @(posedge clk)
		abort <=
			  (p1.valid & p1.ready)
			| (p2.valid & p2.ready)
			| (p3.valid & p3.ready);

endmodule

module gfx_shader_writeback_arbiter4
(
	input  logic     clk,
	                 rst_n,

	       gfx_wb.rx p0,
	                 p1,
	                 p2,
	                 p3,

	       gfx_wb.tx out
);

	assert property (
		@(posedge clk)
		disable iff (~rst_n)

		(p0.ready & out.ready)
	);

	gfx_wb p0_p1(), p2_p3();

	gfx_shader_writeback_arbiter2_prio arbiter_p0_p1
	(
		.clk,
		.rst_n,
		.a(p0),
		.b(p1),
		.out(p0_p1.tx)
	);

	gfx_shader_writeback_arbiter2_prio arbiter_p2_p3
	(
		.clk,
		.rst_n,
		.a(p2),
		.b(p3),
		.out(p2_p3.tx)
	);

	gfx_shader_writeback_arbiter2_prio arbiter_out
	(
		.clk,
		.rst_n,
		.a(p0_p1.rx),
		.b(p2_p3.rx),
		.out
	);

endmodule

module gfx_shader_writeback_arbiter2_prio
(
	input  logic     clk,
	                 rst_n,

	       gfx_wb.rx a,
	                 b,

	       gfx_wb.tx out
);

	assign a.ready = out.ready | ~out.valid;
	assign b.ready = (out.ready | ~out.valid) & ~a.valid;

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			out.valid <= 0;
		else
			out.valid <= (out.valid & ~out.ready) | a.valid | b.valid;

	always_ff @(posedge clk)
		if (out.ready | ~out.valid) begin
			out.dest <= a.valid ? a.dest : b.dest;
			out.lanes <= a.valid ? a.lanes : b.lanes;
			out.group <= a.valid ? a.group : b.group;
			out.scalar <= a.valid ? a.scalar : b.scalar;
			out.writeback <= a.valid ? a.writeback : b.writeback;

			out.mask <= a.valid ? a.mask : b.mask;
			out.mask_update <= a.valid ? a.mask_update : b.mask_update;

			out.pc_add <= a.valid ? a.pc_add : b.pc_add;
			out.pc_inc <= a.valid ? a.pc_inc : b.pc_inc;
			out.pc_update <= a.valid ? a.pc_update : b.pc_update;
		end

endmodule

module gfx_shader_writeback
import gfx::*;
(
	input  logic                 clk,
	                             rst_n,

	       gfx_wb.rx             wb,

	       gfx_regfile_io.wb     regs,

	output logic                 loop_valid,
	output group_id              loop_group,

	       gfx_shader_setup.core setup
);

	struct
	{
		group_id  group;
		word      lanes[SHADER_LANES];
		pc_offset pc_add;
		lane_mask mask;
		vgpr_num  vgpr;
		logic     pc_update,
		          mask_update,
		          vgpr_update;
	} loop_hold[REGFILE_STAGES], loop_out;

	logic loop_valid_hold[REGFILE_STAGES], loop_out_valid, mask_wb, scalar_wb,
	      setup_gpr, setup_mask, setup_submit;

	assign wb.ready = 1;

	assign loop_out = loop_hold[REGFILE_STAGES - 1];
	assign loop_out_valid = loop_valid_hold[REGFILE_STAGES - 1];

	assign loop_valid = loop_out_valid | setup_submit;

	assign regs.pc_back_group = wb.group;
	assign regs.mask_back_group = wb.group;

	assign regs.pc_wb_write = (loop_out_valid & loop_out.pc_update) | setup_submit;
	assign regs.mask_wb_write = mask_wb | setup_mask;
	assign regs.sgpr_write.write = scalar_wb | setup_gpr;

	assign regs.vgpr_write.vgpr = loop_out.vgpr;
	assign regs.vgpr_write.group = loop_out.group;

	assign mask_wb = loop_out_valid & loop_out.mask_update;
	assign scalar_wb = wb.valid & wb.writeback & wb.scalar;

	always_comb begin
		loop_group = setup.write.group;
		regs.pc_wb = setup.write.pc;
		regs.pc_wb_group = setup.write.group;

		if (loop_out_valid) begin
			loop_group = loop_out.group;
			regs.pc_wb = regs.pc_back + word_ptr'(loop_out.pc_add);
			regs.pc_wb_group = loop_out.group;
		end

		regs.mask_wb = setup.write.mask;
		regs.mask_wb_group = setup.write.group;

		if (mask_wb) begin
			regs.mask_wb = loop_out.mask;
			regs.mask_wb_group = loop_out.group;
		end

		regs.sgpr_write.data = setup.write.gpr_value;
		regs.sgpr_write.sgpr = setup.write.gpr;
		regs.sgpr_write.group = setup.write.group;

		if (scalar_wb) begin
			regs.sgpr_write.data = wb.lanes[0];
			regs.sgpr_write.sgpr = wb.dest;
			regs.sgpr_write.group = wb.group;
		end

		for (int i = 0; i < SHADER_LANES; ++i)
			regs.vgpr_write.data[i] = loop_out.lanes[i];

		regs.vgpr_write.mask = regs.mask_back;
		if (~loop_out_valid | ~loop_out.vgpr_update)
			regs.vgpr_write.mask = '0;
	end

	always_ff @(posedge clk) begin
		// Blocking assignments por bug de verilator (ver for de lanes abajo)

		for (int i = REGFILE_STAGES - 1; i > 0; --i)
			loop_hold[i] = loop_hold[i - 1];

		loop_hold[0].mask = wb.mask;
		loop_hold[0].vgpr = wb.dest.vgpr;
		loop_hold[0].group = wb.group;
		loop_hold[0].pc_add = wb.pc_add;
		loop_hold[0].pc_update = wb.pc_update;
		loop_hold[0].mask_update = wb.mask_update;
		loop_hold[0].vgpr_update = wb.writeback & ~wb.scalar;

		// https://github.com/verilator/verilator/issues/4804
		for (int i = 0; i < SHADER_LANES; ++i)
			loop_hold[0].lanes[i] = wb.lanes[i];

		if (wb.pc_inc)
			loop_hold[0].pc_add = pc_offset'(1);
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			setup_gpr <= 0;
			setup_mask <= 0;
			setup_submit <= 0;

			setup.set_done.gpr <= 0;
			setup.set_done.mask <= 0;
			setup.set_done.submit <= 0;

			for (int i = 0; i < $size(loop_valid_hold); ++i)
				loop_valid_hold[i] <= 0;
		end else begin
			setup_gpr <= (setup_gpr & scalar_wb) | setup.write.gpr_set;
			setup_mask <= (setup_mask & mask_wb) | setup.write.mask_set;
			setup_submit <= (setup_submit & loop_out_valid) | setup.write.pc_set;

			setup.set_done.gpr <= setup_gpr & ~scalar_wb;
			setup.set_done.mask <= setup_mask & ~mask_wb;
			setup.set_done.submit <= setup_submit & ~loop_out_valid;

			loop_valid_hold[0] <= wb.valid;
			for (int i = 1; i < REGFILE_STAGES; ++i)
				loop_valid_hold[i] <= loop_valid_hold[i - 1];
		end

endmodule
