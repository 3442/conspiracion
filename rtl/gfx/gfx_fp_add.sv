`include "gfx/gfx_defs.sv"

module gfx_fp_add
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
`else
	fp a_pop, b_pop;

	assign q = $c("taller::fp_add(", a_pop, ", ", b_pop, ")");

	gfx_pipes #(.WIDTH($bits(a)), .DEPTH(`FP_ADD_STAGES)) a_pipes
	(
		.in(a),
		.out(a_pop),
		.*
	);

	gfx_pipes #(.WIDTH($bits(b)), .DEPTH(`FP_ADD_STAGES)) b_pipes
	(
		.in(b),
		.out(b_pop),
		.*
	);
`endif

endmodule
