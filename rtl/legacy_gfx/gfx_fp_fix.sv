`include "gfx/gfx_defs.sv"

module gfx_fp_fix
(
	input  logic clk,

	input  fp    in,
	input  logic stall,

	output fixed out
);

`ifndef VERILATOR
	ip_fp_fix ip_fix
	(
		.a(in),
		.q(out),
		.en(!stall),
		.areset(0),
		.*
	);
`else
	fp pop;

	assign out = $c("taller::fp_fix(", pop, ")");

	gfx_pipes #(.WIDTH($bits(in)), .DEPTH(`FP_FIX_STAGES)) pipes
	(
		.out(pop),
		.*
	);
`endif

endmodule
