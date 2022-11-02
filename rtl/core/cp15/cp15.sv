`include "core/uarch.sv"

module core_cp15
(
	input  logic         clk,
	                     transfer,
	input  coproc_decode dec,
	input  word          write,

	output word          read
);

endmodule
