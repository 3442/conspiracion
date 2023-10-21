`include "gfx/gfx_defs.sv"

module fp_mul
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  fp    a,
	             b,

	output logic done,
	output fp    q
);

	pipelined_flow #(.STAGES(`FP_MUL_STAGES)) stages
	(
		.*
	);

`ifndef VERILATOR
	ip_fp_mul ip_mul
	(
		.en(1),
		.areset(0),
		.*
	);
`endif

endmodule
