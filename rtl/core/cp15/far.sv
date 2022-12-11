`include "core/uarch.sv"
`include "core/cp15/map.sv"

module core_cp15_far
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  cp_opcode op2,
	input  word      write,

	output word      read
);

	word far;

	assign read = far;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			far <= 0;
		else if(transfer && !load)
			far <= write;

endmodule
