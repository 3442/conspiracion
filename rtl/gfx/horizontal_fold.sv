`include "gfx/gfx_defs.sv"

// Asume que N es una potencia de 2
module horizontal_fold
#(parameter N=1)
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  fp    vec[N - 1:0],

	output logic done,
	output fp    q
);

	fp q_left, q_right;
	logic halves_done;

	generate
		if (N > 1) begin
			horizontal_fold #(.N(N / 2)) left
			(
				.q(q_left),
				.vec(vec[N - 1:N / 2]),
				.done(halves_done),
				.*
			);

			horizontal_fold #(.N(N / 2)) right
			(
				.q(q_right),
				.vec(vec[N / 2 - 1:0]),
				.done(),
				.*
			);

			fp_add fold
			(
				.a(q_left),
				.b(q_right),
				.start(halves_done),
				.*
			);
		end else begin
			assign q = vec[0];
			assign done = start;
		end
	endgenerate

endmodule
