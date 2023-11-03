`include "gfx/gfx_defs.sv"

module gfx_mat_mat
(
	input  logic clk,
	             rst_n,

	input  mat4  a,
	             b,
	input  logic in_valid,
	             out_ready,

	output mat4  q,
	output logic in_ready,
	             out_valid
);

	mat4 a_hold, b_hold, b_transpose, q_hold, q_transpose, mul_b;
	vec4 mul_q;
	logic mul_in_ready, mul_in_valid, mul_out_ready, mul_out_valid;
	index4 in_index, out_index;

	assign in_ready = mul_in_ready && in_index == `INDEX4_MIN;
	assign out_valid = mul_out_valid && out_index == `INDEX4_MAX;

	assign mul_in_valid = in_valid || in_index != `INDEX4_MIN;
	assign mul_out_ready = out_ready || out_index != `INDEX4_MAX;

	gfx_transpose transpose_b
	(
		.in(b),
		.out(b_transpose)
	);

	gfx_mat_vec mul
	(
		.a(in_index == `INDEX4_MIN ? a : a_hold),
		.x(mul_b[in_index]),
		.q(mul_q),
		.in_ready(mul_in_ready),
		.in_valid(mul_in_valid),
		.out_ready(mul_out_ready),
		.out_valid(mul_out_valid),
		.*
	);

	gfx_transpose transpose_q
	(
		.in(q_transpose),
		.out(q)
	);

	always_comb begin
		mul_b = b_hold;
		mul_b[0] = b_transpose[0];

		q_transpose = q_hold;
		q_transpose[`VECS_PER_MAT - 1] = mul_q;
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			in_index <= `INDEX4_MIN;
			out_index <= `INDEX4_MIN;
		end else begin
			if (mul_in_ready && mul_in_valid)
				in_index <= in_index + 1;

			if (mul_out_ready && mul_out_valid)
				out_index <= out_index + 1;
		end

	always_ff @(posedge clk) begin
		if (in_ready) begin
			a_hold <= a;
			b_hold <= b_transpose;
		end

		if (mul_out_ready && mul_out_valid)
			q_hold[out_index] <= mul_q;
	end

endmodule
