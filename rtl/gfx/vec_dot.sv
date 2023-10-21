`include "gfx/gfx_defs.sv"

module vec_dot
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  vec4  a,
		         b,

	output logic done,
	output fp    q
);

	vec4 products;
	logic dones[`FLOATS_PER_VEC];

	horizontal_fold #(.N(`FLOATS_PER_VEC)) fold
	(
		.start(dones[0]),
		.vec(products),
		.*
	);

	genvar i;
	generate
		for (i = 0; i < `FLOATS_PER_VEC; ++i) begin: entries
			fp_mul entry_i
			(
				.a(a[i]),
				.b(b[i]),
				.done(dones[i]),
				.q(products[i]),
				.*
			);
		end
	endgenerate

endmodule
