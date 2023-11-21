`include "gfx/gfx_defs.sv"

module gfx_sp_combiner
(
	input  logic     clk,
	                 rst_n,

	input  mat4      a,
	                 b,
	input  insn_deco deco,
	input  logic     in_valid,
	output logic     in_ready,

	output wb_op     wb,
	input  logic     wb_ready,
	output logic     wb_valid
);

	wb_op wb_out;
	logic mul_ready, mul_valid, fifo_ready, fifo_valid, skid_ready, out_stall;

	assign in_ready = mul_ready && fifo_ready;

	gfx_mat_mat mul
	(
		.q(wb_out.data),
		.in_ready(mul_ready),
		.in_valid(in_valid && fifo_ready),
		.out_ready(skid_ready && fifo_valid),
		.out_valid(mul_valid),
		.*
	);

	gfx_fifo #(.WIDTH($bits(vreg_num)), .DEPTH(`GFX_SP_COMBINER_FIFO_DEPTH)) depth
	(
		.in(deco.dst),
		.out(wb_out.dst),
		.in_ready(fifo_ready),
		.in_valid(in_valid && mul_ready),
		.out_ready(skid_ready && mul_valid),
		.out_valid(fifo_valid),
		.*
	);

	gfx_skid_flow out_flow
	(
		.stall(out_stall),
		.in_ready(skid_ready),
		.in_valid(fifo_valid && mul_valid),
		.out_ready(wb_ready),
		.out_valid(wb_valid),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(wb))) out_skid
	(
		.in(wb_out),
		.out(wb),
		.stall(out_stall),
		.*
	);

endmodule
