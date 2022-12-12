`include "core/uarch.sv"
`include "core/cp15/map.sv"

module core_cp15_far
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,

	input  logic     fault_register,
	input  ptr       fault_addr,

	output word      read /*verilator public*/
);

	word far;

	assign read = far;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			far <= 0;
		else if(fault_register)
			far <= {fault_addr, 2'b00};
		else if(transfer && !load)
			far <= write;

endmodule
