module intc
(
	input  logic       clk,
	                   rst_n,

	input  logic       irq_timer,
	                   irq_jtaguart,

	input logic        avl_address,
	                   avl_read,
	                   avl_write,
	input  logic[31:0] avl_writedata,

	output logic       avl_irq,
	output logic[31:0] avl_readdata
);

	logic[31:0] status, mask;

	assign status = {30'b0, irq_jtaguart, irq_timer} & mask;
	assign avl_irq = |status;
	assign avl_readdata = avl_address ? mask : status;

	always @(posedge clk or negedge rst_n)
		if(!rst_n)
			mask <= 0;
		else if(avl_write && avl_address)
			mask <= avl_writedata;

endmodule
