`include "gfx/gfx_defs.sv"

module vec_dot
(
	input  logic clk,

	input  logic stall_mul,
	             stall_fold,
	             feedback,
	             feedback_last,

	input  vec4  a,
		         b,

	output fp    q
);

	vec4 products_fold, products_mul;

	horizontal_fold fold
	(
		.vec(products_fold),
		.stall(stall_fold),
		.*
	);

	genvar i;
	generate
		for (i = 0; i < `FLOATS_PER_VEC; ++i) begin: entries
			fp_mul entry_i
			(
				.a(a[i]),
				.b(b[i]),
				.q(products_mul[i]),
				.stall(stall_mul),
				.*
			);

			skid_buf #(.WIDTH($bits(vec4))) skid_i
			(
				.in(products_mul[i]),
				.out(products_fold[i]),
				.stall(stall_mul),
				.*
			);
		end
	endgenerate

endmodule
