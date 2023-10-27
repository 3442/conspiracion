`include "gfx/gfx_defs.sv"

module horizontal_fold
(
	input  logic  clk,

	input  vec4   vec,
	input  logic  stall,
	              feedback,
	              feedback_last,

	output fp     q
);

	fp q_add;
	vec2 feedback_vec, queued[`FP_ADD_STAGES];

	assign feedback_vec = queued[`FP_ADD_STAGES - 1];

	fp_add add
	(
		.a(feedback ? q_add : vec[0]),
		.b(feedback ? feedback_vec[feedback_last] : vec[1]),
		.q(q_add),
		.*
	);

	skid_buf #(.WIDTH($bits(q))) skid
	(
		.in(q_add),
		.out(q),
		.*
	);

	always_ff @(posedge clk)
		if (!stall) begin
			if (feedback)
				queued[0] <= feedback_vec;
			else begin
				queued[0][0] <= vec[2];
				queued[0][1] <= vec[3];
			end
		end

	genvar i;
	generate
		for (i = 1; i < `FP_ADD_STAGES; ++i) begin: stages
			always_ff @(posedge clk)
				if (!stall)
					queued[i] <= queued[i - 1];
		end
	endgenerate

endmodule
