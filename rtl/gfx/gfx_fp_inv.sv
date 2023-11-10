`include "gfx/gfx_defs.sv"

module gfx_fp_inv
(
	input  logic clk,

	input  fp    a,
	input  logic stall,

	output fp    q
);

`ifndef VERILATOR
	ip_fp_inv ip_inv
	(
		.en(!stall),
		.areset(0),
		.*
	);
`else
	fp a_pop;

	assign q = $c("taller::fp_inv(", a_pop, ")");

	gfx_pipes #(.WIDTH($bits(a)), .DEPTH(`FP_INV_STAGES)) a_pipes
	(
		.in(a),
		.out(a_pop),
		.*
	);
`endif

endmodule
