`include "gfx/gfx_defs.sv"

module fp_add
(
	input  logic clk,

	input  fp    a,
	             b,
	input  logic stall,

	output fp    q
);

`ifndef VERILATOR
	ip_fp_add ip_add
	(
		.en(!stall),
		.areset(0),
		.*
	);
`endif

endmodule
