module sim_slave
(
	input  logic       clk,

	input  logic       waitrequest,
	input  logic[31:0] readdata,
	output logic[31:0] address,
	                   writedata,
	output logic       read,
	                   write
);

	logic[31:0] avl_address /*verilator public_flat_rw @(negedge clk)*/;
	logic       avl_read /*verilator public_flat_rw @(negedge clk)*/;
	logic       avl_write /*verilator public_flat_rw @(negedge clk)*/;
	logic[31:0] avl_readdata /*verilator public*/;
	logic[31:0] avl_writedata /*verilator public_flat_rw @(negedge clk)*/;
	logic       avl_waitrequest /*verilator public*/;

	assign read = avl_read;
	assign write = avl_write;
	assign address = avl_address;
	assign writedata = avl_writedata;

	assign avl_readdata = readdata;
	assign avl_waitrequest = waitrequest;

endmodule
