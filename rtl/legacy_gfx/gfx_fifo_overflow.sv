`include "gfx/gfx_defs.sv"

module gfx_fifo_overflow
#(parameter DEPTH=0)
(
	input  logic clk,
	             rst_n,

	input  logic down,
	             out_ready,
	             out_valid,

	output logic empty,
	             down_safe
);

	logic up;
	logic[$clog2(DEPTH + 1) - 1:0] pending;

	assign up = out_ready && out_valid;
	assign empty = pending == 0;
	assign down_safe = up || pending < DEPTH - 1;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			pending <= 0;
		else begin
			if (up && !down)
				pending <= pending - 1;
			else if (!up && down)
				pending <= pending + 1;
		end

endmodule
