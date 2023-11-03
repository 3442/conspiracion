`include "gfx/gfx_defs.sv"

module gfx_perspective_flow
(
	input  logic clk,
	             rst_n,

	input  logic vertex_start,
	output logic stall,
	             in_start,
	             out_start,

	input  logic in_valid,
	             out_ready,

	output logic in_ready,
	             out_valid
	             stall
);

	localparam STAGES = `FP_INV_STAGES + `FP_MUL_STAGES;

	logic[STAGES - 1:0] start_pipes;

	assign in_start = start_pipes[`FP_INV_STAGES - 1];
	assign out_start = start_pipes[STAGES - 1];

	gfx_pipeline_flow #(.STAGES(STAGES)) flow
	(
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			start_pipes[0] <= 0;
		else if (!stall)
			start_pipes[0] <= in_valid && vertex_start;

	genvar i;
	generate
		for (i = 1; i < STAGES; ++i) begin: pipeline
			always_ff @(posedge clk or negedge rst_n)
				if (!rst_n)
					start_pipes[i] <= 0;
				else if (!stall)
					start_pipes[i] <= start_pipes[i - 1];
		end
	endgenerate

endmodule
