module axi_timer_top
(
	input  logic       clk,
	                   rst_n,

	input  logic[31:0] addr,
	input  logic       avalid,
	input  logic       awrite,
	output logic       aready,

	input  logic       wvalid,
	input  logic[31:0] wdata,
	output logic       wready,

	input  logic       rready,
	output logic[31:0] rdata,
	output logic       rvalid,

	output logic       irq
);

	axi_bus axi();

	assign axi.Master.ADDR = addr;
	assign axi.Master.AVALID = avalid;
	assign axi.Master.AWRITE = awrite;
	assign aready = axi.Master.AREADY;

	assign axi.Master.WVALID = wvalid;
	assign axi.Master.WDATA = wdata;
	assign wready = axi.Master.WREADY;

	assign axi.Master.RREADY = rready;
	assign rdata = axi.Master.RDATA;
	assign rvalid = axi.Master.RVALID;

	axi_timer timer
	(
		.i_clk(clk),
		.i_rst_n(rst_n),
		.o_IRQ(irq),
		.axi_slave(axi.Slave)
	);

endmodule
