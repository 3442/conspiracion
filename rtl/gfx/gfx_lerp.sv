`include "gfx/gfx_defs.sv"

module gfx_lerp
(
	input  logic clk,

	input  fixed b1,
	             b2,
				 q0,
	             q1_q0,
	             q2_q0,
	input  logic stall,

	output fixed q
);

	/* Interpolación lineal, trivializada.
	 *
	 * Esta es la clave: https://fgiesen.wordpress.com/2013/02/06/the-barycentric-conspirac/
	 */

	gfx_fixed_fma_dot fma
	(
		.c(q0),
		.a0(b1),
		.b0(q1_q0),
		.a1(b2),
		.b1(q2_q0),
		.*
	);

endmodule
