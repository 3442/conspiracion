module gfx_fixed_dotadd
(
	input  logic      clk,

	input  gfx::fixed a0,
	                  b0,
	                  a1,
	                  b1,
	                  c,
	input  logic      stall,

	output gfx::fixed q
);

	import gfx::*;

	fixed q0, a1_hold, b1_hold;

	gfx_fixed_muladd muladd_0
	(
		.clk,
		.a(a0),
		.b(b0),
		.c,
		.q(q0),
		.stall
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(FIXED_MULADD_DEPTH)) a_pipes
	(
		.clk,
		.in(a1),
		.out(a1_hold),
		.stall
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(FIXED_MULADD_DEPTH)) b_pipes
	(
		.clk,
		.in(b1),
		.out(b1_hold),
		.stall
	);

	gfx_fixed_muladd muladd_1
	(
		.clk,
		.a(a1_hold),
		.b(b1_hold),
		.c(q0),
		.q,
		.stall
	);

endmodule
