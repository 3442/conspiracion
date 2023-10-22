`include "gfx/gfx_defs.sv"

module fp_mul
(
	input  logic clk,

	input  fp    a,
	             b,
	input  logic stall,

	output fp    q
);

`ifndef VERILATOR
	ip_fp_mul ip_mul
	(
		.en(!stall),
		.areset(0),
		.*
	);
`endif

endmodule
