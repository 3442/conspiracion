`include "core/uarch.sv"
`include "core/cp15/map.sv"

module core_cp15_fsr
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  cp_opcode op2,
	input  word      write,

	output word      read
);

	//TODO
	assign read = 0;

endmodule
