`include "gfx/gfx_defs.sv"

module mat_vec_mul
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  mat4  a,
	input  vec4  x,

	output logic done,
	output vec4  q
);

	logic dones[`FLOATS_PER_VEC];

	assign done = dones[0];

	genvar i;
	generate
		for (i = 0; i < `FLOATS_PER_VEC; ++i) begin: dots
			vec_dot dot_i
			(
				.a(a[i]),
				.b(x),
				.q(q[i]),
				.done(dones[i]),
				.*
			);
		end
	endgenerate

endmodule
