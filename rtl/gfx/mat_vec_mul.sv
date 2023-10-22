`include "gfx/gfx_defs.sv"

module mat_vec_mul
(
	input  logic clk,
	             rst_n,

	input  mat4  a,
	input  vec4  x,
	input  logic in_valid,
	             out_ready,

	output vec4  q,
	output logic in_ready,
	             out_valid
);

	logic stall_mul, stall_fold, mul_ready, mul_valid, feedback, feedback_last;

	pipeline_flow #(.STAGES(`FP_MUL_STAGES)) mul
	(
		.stall(stall_mul),
		.out_ready(mul_ready),
		.out_valid(mul_valid),
		.*
	);

	fold_flow fold
	(
		.stall(stall_fold),
		.in_ready(mul_ready),
		.in_valid(mul_valid),
		.*
	);

	genvar i;
	generate
		for (i = 0; i < `VECS_PER_MAT; ++i) begin: dots
			vec_dot dot_i
			(
				.a(a[i]),
				.b(x),
				.q(q[i]),
				.*
			);
		end
	endgenerate

endmodule
