module gfx_skid_buf
#(int WIDTH = 0)
(
	input  logic              clk,

	input  logic[WIDTH - 1:0] in,
	input  logic              stall,

	output logic[WIDTH - 1:0] out
);

	logic[WIDTH - 1:0] skid;

	assign out = stall ? skid : in;

	always_ff @(posedge clk)
		if (~stall)
			skid <= in;

endmodule
