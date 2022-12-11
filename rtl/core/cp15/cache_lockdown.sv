`include "core/uarch.sv"

module core_cp15_cache_lockdown
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,

	output word      read
);

	//TODO, aunque al parecer Linux no usa esto
	assign read = 0;

endmodule
