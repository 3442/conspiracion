module w3d_interconnect
(
	input  logic     clk,
	                 srst_n,

	       if_axib.s gfx_vram,
	                 host_dbus,
	                 host_ibus,
	                 sgdma_mem,
	                 vdc_stream,

	       if_axib.m dram,

	       if_axil.m gfx_ctrl,
	                 vdc_ctrl,
	                 sgdma_ctrl,
	                 external_io
);

	if_axib dram_host();
	if_axil mmio_axi();

	w3d_interconnect_dram mem
	(
		.clk,
		.srst_n,
		.dram,
		.gfx_vram,
		.host_dbus(dram_host.s),
		.host_ibus,
		.sgdma_mem,
		.vdc_stream
	);

	w3d_interconnect_host_data data
	(
		.clk,
		.srst_n,
		.dram(dram_host.m),
		.host(host_dbus),
		.mmio(mmio_axi.m)
	);

	w3d_interconnect_host_mmio mmio
	(
		.clk,
		.srst_n,
		.host(mmio_axi.s),
		.gfx_ctrl,
		.vdc_ctrl,
		.sgdma_ctrl,
		.external_io
	);

endmodule

module w3d_interconnect_dram
(
	input  logic     clk,
	                 srst_n,

	       if_axib.s gfx_vram,
	                 host_dbus,
	                 host_ibus,
	                 sgdma_mem,
	                 vdc_stream,

	       if_axib.m dram
);

	// VRAM es 0x1c000000..0x1fffffff
	function logic[31:0] vram_addr(logic[31:0] addr);
		return {6'b000111, addr[25:0]};
	endfunction

	defparam
		xbar.NM             = 5,
		xbar.NS             = 1,
		xbar.OPT_LOWPOWER   = 0,
		xbar.SLAVE_ADDR     = '0,
		xbar.SLAVE_MASK     = '0,
		xbar.C_AXI_ID_WIDTH = 8;

	//FIXME: Lower-numbered masters (last in {..., ...}) always win

	axixbar xbar
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID({
			sgdma_mem.awvalid,
			gfx_vram.awvalid,
			host_dbus.awvalid,
			host_ibus.awvalid,
			vdc_stream.awvalid
		}),
		.S_AXI_AWREADY({
			sgdma_mem.awready,
			gfx_vram.awready,
			host_dbus.awready,
			host_ibus.awready,
			vdc_stream.awready
		}),
		.S_AXI_AWID({
			sgdma_mem.awid,
			gfx_vram.awid,
			host_dbus.awid,
			host_ibus.awid,
			vdc_stream.awid
		}),
		.S_AXI_AWADDR({
			sgdma_mem.awaddr,
			vram_addr(gfx_vram.awaddr),
			host_dbus.awaddr,
			host_ibus.awaddr,
			vram_addr(vdc_stream.awaddr)
		}),
		.S_AXI_AWLEN({
			sgdma_mem.awlen,
			gfx_vram.awlen,
			host_dbus.awlen,
			host_ibus.awlen,
			vdc_stream.awlen
		}),
		.S_AXI_AWSIZE({
			sgdma_mem.awsize,
			gfx_vram.awsize,
			host_dbus.awsize,
			host_ibus.awsize,
			vdc_stream.awsize
		}),
		.S_AXI_AWBURST({
			sgdma_mem.awburst,
			gfx_vram.awburst,
			host_dbus.awburst,
			host_ibus.awburst,
			vdc_stream.awburst
		}),
		.S_AXI_AWLOCK('0),
		.S_AXI_AWCACHE('0),
		.S_AXI_AWPROT('0),
		.S_AXI_AWQOS('0),

		.S_AXI_WVALID({
			sgdma_mem.wvalid,
			gfx_vram.wvalid,
			host_dbus.wvalid,
			host_ibus.wvalid,
			vdc_stream.wvalid
		}),
		.S_AXI_WREADY({
			sgdma_mem.wready,
			gfx_vram.wready,
			host_dbus.wready,
			host_ibus.wready,
			vdc_stream.wready
		}),
		.S_AXI_WDATA({
			sgdma_mem.wdata,
			gfx_vram.wdata,
			host_dbus.wdata,
			host_ibus.wdata,
			vdc_stream.wdata
		}),
		.S_AXI_WSTRB({
			sgdma_mem.wstrb,
			gfx_vram.wstrb,
			host_dbus.wstrb,
			host_ibus.wstrb,
			vdc_stream.wstrb
		}),
		.S_AXI_WLAST({
			sgdma_mem.wlast,
			gfx_vram.wlast,
			host_dbus.wlast,
			host_ibus.wlast,
			vdc_stream.wlast
		}),

		.S_AXI_BVALID({
			sgdma_mem.bvalid,
			gfx_vram.bvalid,
			host_dbus.bvalid,
			host_ibus.bvalid,
			vdc_stream.bvalid
		}),
		.S_AXI_BREADY({
			sgdma_mem.bready,
			gfx_vram.bready,
			host_dbus.bready,
			host_ibus.bready,
			vdc_stream.bready
		}),
		.S_AXI_BID({
			sgdma_mem.bid,
			gfx_vram.bid,
			host_dbus.bid,
			host_ibus.bid,
			vdc_stream.bid
		}),
		.S_AXI_BRESP({
			sgdma_mem.bresp,
			gfx_vram.bresp,
			host_dbus.bresp,
			host_ibus.bresp,
			vdc_stream.bresp
		}),

		.S_AXI_ARVALID({
			sgdma_mem.arvalid,
			gfx_vram.arvalid,
			host_dbus.arvalid,
			host_ibus.arvalid,
			vdc_stream.arvalid
		}),
		.S_AXI_ARREADY({
			sgdma_mem.arready,
			gfx_vram.arready,
			host_dbus.arready,
			host_ibus.arready,
			vdc_stream.arready
		}),
		.S_AXI_ARID({
			sgdma_mem.arid,
			gfx_vram.arid,
			host_dbus.arid,
			host_ibus.arid,
			vdc_stream.arid
		}),
		.S_AXI_ARADDR({
			sgdma_mem.araddr,
			vram_addr(gfx_vram.araddr),
			host_dbus.araddr,
			host_ibus.araddr,
			vram_addr(vdc_stream.araddr)
		}),
		.S_AXI_ARLEN({
			sgdma_mem.arlen,
			gfx_vram.arlen,
			host_dbus.arlen,
			host_ibus.arlen,
			vdc_stream.arlen
		}),
		.S_AXI_ARSIZE({
			sgdma_mem.arsize,
			gfx_vram.arsize,
			host_dbus.arsize,
			host_ibus.arsize,
			vdc_stream.arsize
		}),
		.S_AXI_ARBURST({
			sgdma_mem.arburst,
			gfx_vram.arburst,
			host_dbus.arburst,
			host_ibus.arburst,
			vdc_stream.arburst
		}),
		.S_AXI_ARLOCK('0),
		.S_AXI_ARCACHE('0),
		.S_AXI_ARPROT('0),
		.S_AXI_ARQOS('0),

		.S_AXI_RVALID({
			sgdma_mem.rvalid,
			gfx_vram.rvalid,
			host_dbus.rvalid,
			host_ibus.rvalid,
			vdc_stream.rvalid
		}),
		.S_AXI_RREADY({
			sgdma_mem.rready,
			gfx_vram.rready,
			host_dbus.rready,
			host_ibus.rready,
			vdc_stream.rready
		}),
		.S_AXI_RID({
			sgdma_mem.rid,
			gfx_vram.rid,
			host_dbus.rid,
			host_ibus.rid,
			vdc_stream.rid
		}),
		.S_AXI_RDATA({
			sgdma_mem.rdata,
			gfx_vram.rdata,
			host_dbus.rdata,
			host_ibus.rdata,
			vdc_stream.rdata
		}),
		.S_AXI_RRESP({
			sgdma_mem.rresp,
			gfx_vram.rresp,
			host_dbus.rresp,
			host_ibus.rresp,
			vdc_stream.rresp
		}),
		.S_AXI_RLAST({
			sgdma_mem.rlast,
			gfx_vram.rlast,
			host_dbus.rlast,
			host_ibus.rlast,
			vdc_stream.rlast
		}),

		.M_AXI_AWVALID(dram.awvalid),
		.M_AXI_AWREADY(dram.awready),
		.M_AXI_AWID(dram.awid),
		.M_AXI_AWADDR(dram.awaddr),
		.M_AXI_AWLEN(dram.awlen),
		.M_AXI_AWSIZE(dram.awsize),
		.M_AXI_AWBURST(dram.awburst),
		.M_AXI_AWLOCK(),
		.M_AXI_AWCACHE(),
		.M_AXI_AWPROT(),
		.M_AXI_AWQOS(),

		.M_AXI_WVALID(dram.wvalid),
		.M_AXI_WREADY(dram.wready),
		.M_AXI_WDATA(dram.wdata),
		.M_AXI_WSTRB(dram.wstrb),
		.M_AXI_WLAST(dram.wlast),

		.M_AXI_BVALID(dram.bvalid),
		.M_AXI_BREADY(dram.bready),
		.M_AXI_BID(dram.bid),
		.M_AXI_BRESP(dram.bresp),

		.M_AXI_ARVALID(dram.arvalid),
		.M_AXI_ARREADY(dram.arready),
		.M_AXI_ARID(dram.arid),
		.M_AXI_ARADDR(dram.araddr),
		.M_AXI_ARLEN(dram.arlen),
		.M_AXI_ARSIZE(dram.arsize),
		.M_AXI_ARBURST(dram.arburst),
		.M_AXI_ARLOCK(),
		.M_AXI_ARCACHE(),
		.M_AXI_ARPROT(),
		.M_AXI_ARQOS(),

		.M_AXI_RVALID(dram.rvalid),
		.M_AXI_RREADY(dram.rready),
		.M_AXI_RID(dram.rid),
		.M_AXI_RDATA(dram.rdata),
		.M_AXI_RRESP(dram.rresp),
		.M_AXI_RLAST(dram.rlast)
	);

endmodule

module w3d_interconnect_host_data
(
	input  logic     clk,
	                 srst_n,

	       if_axib.s host,

	       if_axib.m dram,
	       if_axil.m mmio
);

	localparam logic[31:0]
		DRAM_BASE = 32'h0000_0000,
		DRAM_MASK = 32'he000_0000,
		MMIO_BASE = 32'h2000_0000,
		MMIO_MASK = 32'he000_0000;

	if_axib mmio_full();

	assign host.bid = '0;
	assign host.rid = '0;

	assign dram.arid = '0;
	assign dram.awid = '0;

	assign mmio_full.s.bid = '0;
	assign mmio_full.s.rid = '0;
	assign mmio_full.m.arid = '0;
	assign mmio_full.m.awid = '0;

	defparam xbar.NM = 1;
	defparam xbar.NS = 2;
	defparam xbar.OPT_LOWPOWER = 0;

	defparam xbar.SLAVE_ADDR = {
		MMIO_BASE,
		DRAM_BASE
	};

	defparam xbar.SLAVE_MASK = {
		MMIO_MASK,
		DRAM_MASK
	};

	axixbar xbar
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID(host.awvalid),
		.S_AXI_AWREADY(host.awready),
		.S_AXI_AWID('0),
		.S_AXI_AWADDR(host.awaddr),
		.S_AXI_AWLEN(host.awlen),
		.S_AXI_AWSIZE(host.awsize),
		.S_AXI_AWBURST(host.awburst),
		.S_AXI_AWLOCK('0),
		.S_AXI_AWCACHE('0),
		.S_AXI_AWPROT('0),
		.S_AXI_AWQOS('0),

		.S_AXI_WVALID(host.wvalid),
		.S_AXI_WREADY(host.wready),
		.S_AXI_WDATA(host.wdata),
		.S_AXI_WSTRB(host.wstrb),
		.S_AXI_WLAST(host.wlast),

		.S_AXI_BVALID(host.bvalid),
		.S_AXI_BREADY(host.bready),
		.S_AXI_BID(),
		.S_AXI_BRESP(host.bresp),

		.S_AXI_ARVALID(host.arvalid),
		.S_AXI_ARREADY(host.arready),
		.S_AXI_ARID('0),
		.S_AXI_ARADDR(host.araddr),
		.S_AXI_ARLEN(host.arlen),
		.S_AXI_ARSIZE(host.arsize),
		.S_AXI_ARBURST(host.arburst),
		.S_AXI_ARLOCK('0),
		.S_AXI_ARCACHE('0),
		.S_AXI_ARPROT('0),
		.S_AXI_ARQOS('0),

		.S_AXI_RVALID(host.rvalid),
		.S_AXI_RREADY(host.rready),
		.S_AXI_RID(),
		.S_AXI_RDATA(host.rdata),
		.S_AXI_RRESP(host.rresp),
		.S_AXI_RLAST(host.rlast),

		.M_AXI_AWVALID({
			mmio_full.m.awvalid,
			dram.awvalid
		}),
		.M_AXI_AWREADY({
			mmio_full.m.awready,
			dram.awready
		}),
		.M_AXI_AWID(),
		.M_AXI_AWADDR({
			mmio_full.m.awaddr,
			dram.awaddr
		}),
		.M_AXI_AWLEN({
			mmio_full.m.awlen,
			dram.awlen
		}),
		.M_AXI_AWSIZE({
			mmio_full.m.awsize,
			dram.awsize
		}),
		.M_AXI_AWBURST({
			mmio_full.m.awburst,
			dram.awburst
		}),
		.M_AXI_AWLOCK(),
		.M_AXI_AWCACHE(),
		.M_AXI_AWPROT(),
		.M_AXI_AWQOS(),

		.M_AXI_WVALID({
			mmio_full.m.wvalid,
			dram.wvalid
		}),
		.M_AXI_WREADY({
			mmio_full.m.wready,
			dram.wready
		}),
		.M_AXI_WDATA({
			mmio_full.m.wdata,
			dram.wdata
		}),
		.M_AXI_WSTRB({
			mmio_full.m.wstrb,
			dram.wstrb
		}),
		.M_AXI_WLAST({
			mmio_full.m.wlast,
			dram.wlast
		}),

		.M_AXI_BVALID({
			mmio_full.m.bvalid,
			dram.bvalid
		}),
		.M_AXI_BREADY({
			mmio_full.m.bready,
			dram.bready
		}),
		.M_AXI_BID('0),
		.M_AXI_BRESP({
			mmio_full.m.bresp,
			dram.bresp
		}),

		.M_AXI_ARVALID({
			mmio_full.m.arvalid,
			dram.arvalid
		}),
		.M_AXI_ARREADY({
			mmio_full.m.arready,
			dram.arready
		}),
		.M_AXI_ARID(),
		.M_AXI_ARADDR({
			mmio_full.m.araddr,
			dram.araddr
		}),
		.M_AXI_ARLEN({
			mmio_full.m.arlen,
			dram.arlen
		}),
		.M_AXI_ARSIZE({
			mmio_full.m.arsize,
			dram.arsize
		}),
		.M_AXI_ARBURST({
			mmio_full.m.arburst,
			dram.arburst
		}),
		.M_AXI_ARLOCK(),
		.M_AXI_ARCACHE(),
		.M_AXI_ARPROT(),
		.M_AXI_ARQOS(),

		.M_AXI_RVALID({
			mmio_full.m.rvalid,
			dram.rvalid
		}),
		.M_AXI_RREADY({
			mmio_full.m.rready,
			dram.rready
		}),
		.M_AXI_RID('0),
		.M_AXI_RDATA({
			mmio_full.m.rdata,
			dram.rdata
		}),
		.M_AXI_RRESP({
			mmio_full.m.rresp,
			dram.rresp
		}),
		.M_AXI_RLAST({
			mmio_full.m.rlast,
			dram.rlast
		})
	);

	defparam mmio_full2lite.C_AXI_ADDR_WIDTH = 32;

	axi2axilite mmio_full2lite
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID(mmio_full.s.awvalid),
		.S_AXI_AWREADY(mmio_full.s.awready),
		.S_AXI_AWID('0),
		.S_AXI_AWADDR(mmio_full.s.awaddr),
		.S_AXI_AWLEN(mmio_full.s.awlen),
		.S_AXI_AWSIZE(mmio_full.s.awsize),
		.S_AXI_AWBURST(mmio_full.s.awburst),
		.S_AXI_AWLOCK('0),
		.S_AXI_AWCACHE('0),
		.S_AXI_AWPROT('0),
		.S_AXI_AWQOS('0),

		.S_AXI_WVALID(mmio_full.s.wvalid),
		.S_AXI_WREADY(mmio_full.s.wready),
		.S_AXI_WDATA(mmio_full.s.wdata),
		.S_AXI_WSTRB(mmio_full.s.wstrb),
		.S_AXI_WLAST(mmio_full.s.wlast),

		.S_AXI_BVALID(mmio_full.s.bvalid),
		.S_AXI_BREADY(mmio_full.s.bready),
		.S_AXI_BID(),
		.S_AXI_BRESP(mmio_full.s.bresp),

		.S_AXI_ARVALID(mmio_full.s.arvalid),
		.S_AXI_ARREADY(mmio_full.s.arready),
		.S_AXI_ARID('0),
		.S_AXI_ARADDR(mmio_full.s.araddr),
		.S_AXI_ARLEN(mmio_full.s.arlen),
		.S_AXI_ARSIZE(mmio_full.s.arsize),
		.S_AXI_ARBURST(mmio_full.s.arburst),
		.S_AXI_ARLOCK('0),
		.S_AXI_ARCACHE('0),
		.S_AXI_ARPROT('0),
		.S_AXI_ARQOS('0),

		.S_AXI_RVALID(mmio_full.s.rvalid),
		.S_AXI_RREADY(mmio_full.s.rready),
		.S_AXI_RID(),
		.S_AXI_RDATA(mmio_full.s.rdata),
		.S_AXI_RRESP(mmio_full.s.rresp),
		.S_AXI_RLAST(mmio_full.s.rlast),

		.M_AXI_AWADDR(mmio.awaddr),
		.M_AXI_AWPROT(),
		.M_AXI_AWVALID(mmio.awvalid),
		.M_AXI_AWREADY(mmio.awready),

		.M_AXI_WDATA(mmio.wdata),
		.M_AXI_WSTRB(),
		.M_AXI_WVALID(mmio.wvalid),
		.M_AXI_WREADY(mmio.wready),

		.M_AXI_BRESP('0),
		.M_AXI_BVALID(mmio.bvalid),
		.M_AXI_BREADY(mmio.bready),

		.M_AXI_ARADDR(mmio.araddr),
		.M_AXI_ARPROT(),
		.M_AXI_ARVALID(mmio.arvalid),
		.M_AXI_ARREADY(mmio.arready),

		.M_AXI_RDATA(mmio.rdata),
		.M_AXI_RRESP('0),
		.M_AXI_RVALID(mmio.rvalid),
		.M_AXI_RREADY(mmio.rready)
	);

endmodule

module w3d_interconnect_host_mmio
(
	input  logic     clk,
	                 srst_n,

	       if_axil.s host,

	       if_axil.m gfx_ctrl,
	                 vdc_ctrl,
	                 sgdma_ctrl,
	                 external_io
);

	localparam logic[31:0]
		GFX_CTRL_BASE    = 32'h2000_0000,
		GFX_CTRL_MASK    = 32'hfc00_0000,
		VDC_CTRL_BASE    = 32'h2400_0000,
		VDC_CTRL_MASK    = 32'hfc00_0000,
		SGDMA_CTRL_BASE  = 32'h2800_0000,
		SGDMA_CTRL_MASK  = 32'hfc00_0000,
		EXTERNAL_IO_BASE = 32'h3000_0000,
		EXTERNAL_IO_MASK = 32'hf000_0000;

	defparam xbar.NM = 1;
	defparam xbar.NS = 4;
	defparam xbar.OPT_LOWPOWER = 0;

	defparam xbar.SLAVE_ADDR = {
		EXTERNAL_IO_BASE,
		SGDMA_CTRL_BASE,
		VDC_CTRL_BASE,
		GFX_CTRL_BASE
	};

	defparam xbar.SLAVE_MASK = {
		EXTERNAL_IO_MASK,
		SGDMA_CTRL_MASK,
		VDC_CTRL_MASK,
		GFX_CTRL_MASK
	};

	axilxbar xbar
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID(host.awvalid),
		.S_AXI_AWREADY(host.awready),
		.S_AXI_AWADDR(host.awaddr),
		.S_AXI_AWPROT('0),

		.S_AXI_WVALID(host.wvalid),
		.S_AXI_WREADY(host.wready),
		.S_AXI_WDATA(host.wdata),
		.S_AXI_WSTRB('1),

		.S_AXI_BVALID(host.bvalid),
		.S_AXI_BREADY(host.bready),
		.S_AXI_BRESP(),

		.S_AXI_ARVALID(host.arvalid),
		.S_AXI_ARREADY(host.arready),
		.S_AXI_ARADDR(host.araddr),
		.S_AXI_ARPROT('0),

		.S_AXI_RVALID(host.rvalid),
		.S_AXI_RREADY(host.rready),
		.S_AXI_RDATA(host.rdata),
		.S_AXI_RRESP(),

		.M_AXI_AWADDR({
			external_io.awaddr,
			sgdma_ctrl.awaddr,
			vdc_ctrl.awaddr,
			gfx_ctrl.awaddr
		}),
		.M_AXI_AWPROT(),
		.M_AXI_AWVALID({
			external_io.awvalid,
			sgdma_ctrl.awvalid,
			vdc_ctrl.awvalid,
			gfx_ctrl.awvalid
		}),
		.M_AXI_AWREADY({
			external_io.awready,
			sgdma_ctrl.awready,
			vdc_ctrl.awready,
			gfx_ctrl.awready
		}),

		.M_AXI_WDATA({
			external_io.wdata,
			sgdma_ctrl.wdata,
			vdc_ctrl.wdata,
			gfx_ctrl.wdata
		}),
		.M_AXI_WSTRB(),
		.M_AXI_WVALID({
			external_io.wvalid,
			sgdma_ctrl.wvalid,
			vdc_ctrl.wvalid,
			gfx_ctrl.wvalid
		}),
		.M_AXI_WREADY({
			external_io.wready,
			sgdma_ctrl.wready,
			vdc_ctrl.wready,
			gfx_ctrl.wready
		}),

		.M_AXI_BRESP('0),
		.M_AXI_BVALID({
			external_io.bvalid,
			sgdma_ctrl.bvalid,
			vdc_ctrl.bvalid,
			gfx_ctrl.bvalid
		}),
		.M_AXI_BREADY({
			external_io.bready,
			sgdma_ctrl.bready,
			vdc_ctrl.bready,
			gfx_ctrl.bready
		}),

		.M_AXI_ARADDR({
			external_io.araddr,
			sgdma_ctrl.araddr,
			vdc_ctrl.araddr,
			gfx_ctrl.araddr
		}),
		.M_AXI_ARPROT(),
		.M_AXI_ARVALID({
			external_io.arvalid,
			sgdma_ctrl.arvalid,
			vdc_ctrl.arvalid,
			gfx_ctrl.arvalid
		}),
		.M_AXI_ARREADY({
			external_io.arready,
			sgdma_ctrl.arready,
			vdc_ctrl.arready,
			gfx_ctrl.arready
		}),

		.M_AXI_RDATA({
			external_io.rdata,
			sgdma_ctrl.rdata,
			vdc_ctrl.rdata,
			gfx_ctrl.rdata
		}),
		.M_AXI_RRESP('0),
		.M_AXI_RVALID({
			external_io.rvalid,
			sgdma_ctrl.rvalid,
			vdc_ctrl.rvalid,
			gfx_ctrl.rvalid
		}),
		.M_AXI_RREADY({
			external_io.rready,
			sgdma_ctrl.rready,
			vdc_ctrl.rready,
			gfx_ctrl.rready
		})
	);

endmodule
