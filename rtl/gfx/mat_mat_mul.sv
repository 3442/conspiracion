`include "gfx/gfx_defs.sv"

module mat_mat_mul
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  mat4  a,
	             b,

	output logic done,
	output mat4  q
);

	logic dones[`VECS_PER_MAT];

	assign done = dones[0];

	genvar i;
	generate
		for (i = 0; i < `VECS_PER_MAT; ++i) begin: columns
			mat_vec_mul column_i
			(
				.x(b[i]),
				.q(q[i]),
				.done(dones[i]),
				.*
			);
		end
	endgenerate

endmodule
