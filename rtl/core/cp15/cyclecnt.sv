`include "core/uarch.sv"

module core_cp15_cyclecnt
(
	input  logic     clk,
	                 rst_n,

	input  logic     halt,

	output word      read
);

	word cyclecnt;

	assign read = cyclecnt;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			cyclecnt <= 0;
		else if(!halt)
			cyclecnt <= cyclecnt + 1;

endmodule
