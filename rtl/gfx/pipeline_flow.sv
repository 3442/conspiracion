`include "gfx/gfx_defs.sv"

module pipeline_flow
#(parameter STAGES=0)
(
	input  logic clk,
	             rst_n,

	input  logic in_valid,
	             out_ready,

	output logic in_ready,
	             out_valid,
	             stall
);

	logic valid[STAGES];

	assign stall = !in_ready;
	assign in_ready = out_ready || !out_valid;
	assign out_valid = valid[STAGES - 1];

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			valid[0] <= 0;
		else if (in_ready)
			valid[0] <= in_valid;

	genvar i;
	generate
		for (i = 1; i < STAGES; ++i) begin: pipeline
			always_ff @(posedge clk or negedge rst_n)
				if (!rst_n)
					valid[i] <= 0;
				else if (in_ready)
					valid[i] <= valid[i - 1];
		end
	endgenerate

endmodule
