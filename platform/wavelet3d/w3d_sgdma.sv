module w3d_sgdma
(
	input  logic     clk,
	                 srst_n,

	       if_axil.s ctrl,

	       if_axib.m mem,

	output  logic    irq
);

	defparam
		engine.C_AXI_ID_WIDTH   = 8,
		engine.C_AXI_ADDR_WIDTH = 32,
		engine.C_AXI_DATA_WIDTH = 32,
		engine.OPT_UNALIGNED    = 0,
		engine.OPT_WRAPMEM      = 1,
		engine.LGMAXBURST       = $clog2(16), //TODO: probar 256
		// The "ABORT_KEY" is a byte that, if written to the control
		// word while the core is running, will cause the data transfer
		// to be aborted.
		engine.ABORT_KEY        = 8'h6d,
		engine.OPT_LOWPOWER     = 1'b0;

	axisgdma engine
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),


		// The AXI4-lite control interface
		.S_AXIL_AWVALID(ctrl.awvalid),
		.S_AXIL_AWREADY(ctrl.awready),
		.S_AXIL_AWADDR(ctrl.awaddr[3:0]),
		.S_AXIL_AWPROT(3'b0),

		.S_AXIL_WVALID(ctrl.wvalid),
		.S_AXIL_WREADY(ctrl.wready),
		.S_AXIL_WDATA(ctrl.wdata),
		.S_AXIL_WSTRB(4'b1111),

		.S_AXIL_BVALID(ctrl.bvalid),
		.S_AXIL_BREADY(ctrl.bready),
		.S_AXIL_BRESP(),
		//
		.S_AXIL_ARVALID(ctrl.arvalid),
		.S_AXIL_ARREADY(ctrl.arready),
		.S_AXIL_ARADDR(ctrl.araddr[3:0]),
		.S_AXIL_ARPROT(3'b0),

		.S_AXIL_RVALID(ctrl.rvalid),
		.S_AXIL_RREADY(ctrl.rready),
		.S_AXIL_RDATA(ctrl.rdata),
		.S_AXIL_RRESP(),

		.M_AXI_AWVALID(mem.awvalid),
		.M_AXI_AWREADY(mem.awready),
		.M_AXI_AWID(mem.awid),
		.M_AXI_AWADDR(mem.awaddr),
		.M_AXI_AWLEN(mem.awlen),
		.M_AXI_AWSIZE(mem.awsize),
		.M_AXI_AWBURST(mem.awburst),
		.M_AXI_AWLOCK(),
		.M_AXI_AWCACHE(),
		.M_AXI_AWPROT(),
		.M_AXI_AWQOS(),

		.M_AXI_WVALID(mem.wvalid),
		.M_AXI_WREADY(mem.wready),
		.M_AXI_WDATA(mem.wdata),
		.M_AXI_WSTRB(mem.wstrb),
		.M_AXI_WLAST(mem.wlast),

		.M_AXI_BVALID(mem.bvalid),
		.M_AXI_BREADY(mem.bready),
		.M_AXI_BID(mem.bid),
		.M_AXI_BRESP(mem.bresp),

		.M_AXI_ARVALID(mem.arvalid),
		.M_AXI_ARREADY(mem.arready),
		.M_AXI_ARID(mem.arid),
		.M_AXI_ARADDR(mem.araddr),
		.M_AXI_ARLEN(mem.arlen),
		.M_AXI_ARSIZE(mem.arsize),
		.M_AXI_ARBURST(mem.arburst),
		.M_AXI_ARLOCK(),
		.M_AXI_ARCACHE(),
		.M_AXI_ARPROT(),
		.M_AXI_ARQOS(),

		.M_AXI_RVALID(mem.rvalid),
		.M_AXI_RREADY(mem.rready),
		.M_AXI_RID(mem.rid),
		.M_AXI_RDATA(mem.rdata),
		.M_AXI_RLAST(mem.rlast),
		.M_AXI_RRESP(mem.rresp),

		.o_int(irq)
	);

endmodule
