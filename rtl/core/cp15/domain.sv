`include "core/uarch.sv"

module core_cp15_domain
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,

	output word      read
);

	word dac;
	assign read = dac;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			dac <= 0;
		else if(transfer && !load)
			dac <= write;

endmodule
