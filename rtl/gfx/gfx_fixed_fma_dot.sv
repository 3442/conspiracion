`include "gfx/gfx_defs.sv"

module gfx_fixed_fma_dot
(
	input  logic clk,

	input  fixed a0,
	             b0,
	             a1,
	             b1,
	             c,
	input  logic stall,

	output fixed q
);

	fixed q0, a1_hold, b1_hold;

	gfx_fixed_fma fma0
	(
		.a(a0),
		.b(b0),
		.q(q0),
		.*
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`FIXED_FMA_STAGES)) a_pipes
	(
		.in(a1),
		.out(a1_hold),
		.*
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`FIXED_FMA_STAGES)) b_pipes
	(
		.in(b1),
		.out(b1_hold),
		.*
	);

	gfx_fixed_fma fma1
	(
		.a(a1_hold),
		.b(b1_hold),
		.c(q0),
		.*
	);

endmodule
