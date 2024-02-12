`include "core/uarch.sv"
`include "core/cp15_map.sv"

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

	// %Warning-SYMRSVDWORD: rtl/core/core_cp15_far.sv:19:7: Symbol matches C++ common word: 'far'
	word far_;

	assign read = far_;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			far_ <= 0;
		else if(fault_register)
			far_ <= {fault_addr, 2'b00};
		else if(transfer && !load)
			far_ <= write;

endmodule
