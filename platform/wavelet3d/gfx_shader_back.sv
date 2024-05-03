module gfx_shader_back
import gfx::*;
(
	input  logic               clk,
	                           rst_n,

	       gfx_front_back.back back,

	       gfx_regfile_io.ab   read_data,
	       gfx_regfile_io.wb   reg_wb
);

	logic abort;

	gfx_wb out_wb(), p0_wb(), p1_wb(), p2_wb(), p3_wb();
	gfx_shake p1_shake(), p2_shake(), p3_shake();

	gfx_shader_abort p0_abort
	(
		.clk,
		.p1(p1_shake.peek),
		.p2(p2_shake.peek),
		.p3(p3_shake.peek),
		.abort
	);

	gfx_fpint p0
	(
		.clk,
		.rst_n,
		.op(back.execute.p0),
		.wb(p0_wb.tx),
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
		.in_shake(p1_shake.rx),
		.read_data
	);

	gfx_shader_sfu p2
	(
		.clk,
		.rst_n,
		.op(back.execute.p2),
		.wb(p2_wb.tx),
		.in_shake(p2_shake.rx),
		.read_data
	);

	gfx_shader_group p3
	(
		.clk,
		.rst_n,
		.op(back.execute.p3),
		.wb(p3_wb.tx),
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
		.regs(reg_wb)
	);

endmodule

module gfx_shader_abort
(
	input  logic          clk,

	       gfx_shake.peek p1,
	                      p2,
	                      p3,

	output logic          abort
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
		.b(p2_p3.tx),
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

	//TODO
	assign a.ready = out.ready;
	assign b.ready = 0;
	assign out.dest = a.dest;
	assign out.lanes = a.lanes;
	assign out.group = a.group;
	assign out.valid = a.valid;
	assign out.scalar = a.scalar;
	assign out.writeback = a.writeback;

endmodule

module gfx_shader_writeback
(
	input  logic             clk,
	                         rst_n,

	       gfx_wb.rx         wb,

	       gfx_regfile_io.wb regs
);

	

endmodule
