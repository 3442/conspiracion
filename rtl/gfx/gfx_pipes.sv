module gfx_pipes
#(parameter WIDTH=0, DEPTH=0)
(
	input  logic              clk,

	input  logic[WIDTH - 1:0] in,
	input  logic              stall,

	output logic[WIDTH - 1:0] out
);

	logic[WIDTH - 1:0] pipes[DEPTH];

	assign out = pipes[DEPTH - 1];

	integer i;
	always_ff @(posedge clk)
		if (!stall) begin
			pipes[0] <= in;

			for (i = 1; i < DEPTH; ++i)
				pipes[i] <= pipes[i - 1];
		end

endmodule
