module pipelined_flow
#(parameter STAGES=0)
(
	input  logic clk,
	             rst_n,

	input  logic start,
	output logic done
);

	logic valid[STAGES];

	assign done = valid[STAGES - 1];

	always_ff @(posedge clk or negedge rst_n)
		valid[0] <= !rst_n ? 0 : start;

	genvar i;
	generate
		for (i = 1; i < STAGES; ++i) begin: pipeline
			always_ff @(posedge clk or negedge rst_n)
				valid[i] <= !rst_n ? 0 : valid[i - 1];
		end
	endgenerate

endmodule
