module gfx_flush_flow
#(parameter STAGES=0)
(
	input  logic clk,
	             rst_n,

	input  logic in_valid,
	             out_ready,

	output logic out_valid,
	             commit,
	             flush
);

	logic was_valid, was_ready;
	logic[STAGES - 1:0] valid;

	assign flush = was_valid && !was_ready;
	assign commit = was_valid && was_ready;
	assign out_valid = valid[STAGES - 1] && !flush;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			was_ready <= 0;
			was_valid <= 0;

			for (integer i = 0; i < STAGES; ++i)
				valid[i] <= 0;
		end else begin
			was_ready <= out_ready;
			was_valid <= out_valid;

			if (!flush)
				valid[0] <= in_valid;
			else
				valid[0] <= 0;

			for (integer i = 1; i < STAGES; ++i)
				if (!flush)
					valid[i] <= valid[i - 1];
				else
					valid[i] <= 0;
		end

endmodule
