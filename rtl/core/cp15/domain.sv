`include "core/uarch.sv"

module core_cp15_domain
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,

	output word      read,
	                 mmu_dac
);

	assign read = mmu_dac;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			mmu_dac <= 0;
		else if(transfer && !load)
			mmu_dac <= write;

endmodule
