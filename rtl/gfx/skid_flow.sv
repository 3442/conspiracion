module skid_flow
(
	input  logic clk,
	             rst_n,

	input  logic in_valid,
	             out_ready,

	output logic in_ready,
	             out_valid,
	             stall
);

	logic was_ready, was_valid;

	assign stall = !in_ready;
	assign in_ready = was_ready || !was_valid;
	assign out_valid = in_valid || was_valid;

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			was_ready <= 0;
			was_valid <= 0;
		end else begin
			was_ready <= out_ready;

			if (!stall)
				was_valid <= in_valid;
		end

endmodule
