`include "core/uarch.sv"

module core_psr
(
	input  logic     clk,
	input  psr_flags alu_flags,

	output psr_flags flags,
	                 next_flags
);

	assign next_flags = alu_flags; //TODO

	always_ff @(posedge clk)
		flags <= next_flags;

	initial flags = 4'b0000;

endmodule
