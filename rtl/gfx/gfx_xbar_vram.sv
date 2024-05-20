module gfx_xbar_vram
(
	input  logic     clk,
	                 srst_n,

	       if_axib.s shader_0_data,
	                 shader_0_insn,

	       if_axib.m vram
);

	defparam xbar.NM = 2;
	defparam xbar.NS = 1;
	defparam xbar.OPT_LOWPOWER = 0;

	defparam
		xbar.SLAVE_ADDR     = '0,
		xbar.SLAVE_MASK     = '0,
		xbar.C_AXI_ID_WIDTH = 8;

	axixbar xbar
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID({
			shader_0_data.awvalid,
			shader_0_insn.awvalid
		}),
		.S_AXI_AWREADY({
			shader_0_data.awready,
			shader_0_insn.awready
		}),
		.S_AXI_AWID({
			shader_0_data.awid,
			shader_0_insn.awid
		}),
		.S_AXI_AWADDR({
			shader_0_data.awaddr,
			shader_0_insn.awaddr
		}),
		.S_AXI_AWLEN({
			shader_0_data.awlen,
			shader_0_insn.awlen
		}),
		.S_AXI_AWSIZE({
			shader_0_data.awsize,
			shader_0_insn.awsize
		}),
		.S_AXI_AWBURST({
			shader_0_data.awburst,
			shader_0_insn.awburst
		}),
		.S_AXI_AWLOCK('0),
		.S_AXI_AWCACHE('0),
		.S_AXI_AWPROT('0),
		.S_AXI_AWQOS('0),

		.S_AXI_WVALID({
			shader_0_data.wvalid,
			shader_0_insn.wvalid
		}),
		.S_AXI_WREADY({
			shader_0_data.wready,
			shader_0_insn.wready
		}),
		.S_AXI_WDATA({
			shader_0_data.wdata,
			shader_0_insn.wdata
		}),
		.S_AXI_WSTRB({
			shader_0_data.wstrb,
			shader_0_insn.wstrb
		}),
		.S_AXI_WLAST({
			shader_0_data.wlast,
			shader_0_insn.wlast
		}),

		.S_AXI_BVALID({
			shader_0_data.bvalid,
			shader_0_insn.bvalid
		}),
		.S_AXI_BREADY({
			shader_0_data.bready,
			shader_0_insn.bready
		}),
		.S_AXI_BID({
			shader_0_data.bid,
			shader_0_insn.bid
		}),
		.S_AXI_BRESP({
			shader_0_data.bresp,
			shader_0_insn.bresp
		}),

		.S_AXI_ARVALID({
			shader_0_data.arvalid,
			shader_0_insn.arvalid
		}),
		.S_AXI_ARREADY({
			shader_0_data.arready,
			shader_0_insn.arready
		}),
		.S_AXI_ARID({
			shader_0_data.arid,
			shader_0_insn.arid
		}),
		.S_AXI_ARADDR({
			shader_0_data.araddr,
			shader_0_insn.araddr
		}),
		.S_AXI_ARLEN({
			shader_0_data.arlen,
			shader_0_insn.arlen
		}),
		.S_AXI_ARSIZE({
			shader_0_data.arsize,
			shader_0_insn.arsize
		}),
		.S_AXI_ARBURST({
			shader_0_data.arburst,
			shader_0_insn.arburst
		}),
		.S_AXI_ARLOCK('0),
		.S_AXI_ARCACHE('0),
		.S_AXI_ARPROT('0),
		.S_AXI_ARQOS('0),

		.S_AXI_RVALID({
			shader_0_data.rvalid,
			shader_0_insn.rvalid
		}),
		.S_AXI_RREADY({
			shader_0_data.rready,
			shader_0_insn.rready
		}),
		.S_AXI_RID({
			shader_0_data.rid,
			shader_0_insn.rid
		}),
		.S_AXI_RDATA({
			shader_0_data.rdata,
			shader_0_insn.rdata
		}),
		.S_AXI_RRESP({
			shader_0_data.rresp,
			shader_0_insn.rresp
		}),
		.S_AXI_RLAST({
			shader_0_data.rlast,
			shader_0_insn.rlast
		}),

		.M_AXI_AWVALID(vram.awvalid),
		.M_AXI_AWREADY(vram.awready),
		.M_AXI_AWID(vram.awid),
		.M_AXI_AWADDR(vram.awaddr),
		.M_AXI_AWLEN(vram.awlen),
		.M_AXI_AWSIZE(vram.awsize),
		.M_AXI_AWBURST(vram.awburst),
		.M_AXI_AWLOCK(),
		.M_AXI_AWCACHE(),
		.M_AXI_AWPROT(),
		.M_AXI_AWQOS(),

		.M_AXI_WVALID(vram.wvalid),
		.M_AXI_WREADY(vram.wready),
		.M_AXI_WDATA(vram.wdata),
		.M_AXI_WSTRB(vram.wstrb),
		.M_AXI_WLAST(vram.wlast),

		.M_AXI_BVALID(vram.bvalid),
		.M_AXI_BREADY(vram.bready),
		.M_AXI_BID(vram.bid),
		.M_AXI_BRESP(vram.bresp),

		.M_AXI_ARVALID(vram.arvalid),
		.M_AXI_ARREADY(vram.arready),
		.M_AXI_ARID(vram.arid),
		.M_AXI_ARADDR(vram.araddr),
		.M_AXI_ARLEN(vram.arlen),
		.M_AXI_ARSIZE(vram.arsize),
		.M_AXI_ARBURST(vram.arburst),
		.M_AXI_ARLOCK(),
		.M_AXI_ARCACHE(),
		.M_AXI_ARPROT(),
		.M_AXI_ARQOS(),

		.M_AXI_RVALID(vram.rvalid),
		.M_AXI_RREADY(vram.rready),
		.M_AXI_RID(vram.rid),
		.M_AXI_RDATA(vram.rdata),
		.M_AXI_RRESP(vram.rresp),
		.M_AXI_RLAST(vram.rlast)
	);

endmodule
