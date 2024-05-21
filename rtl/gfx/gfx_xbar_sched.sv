module gfx_xbar_sched
import gfx::*;
(
	input  logic     clk,
	                 srst_n,

	       if_axil.s sched,

	       if_axib.m vram,

	       if_axil.m debug,
	                 bootrom,
	                 shader_0,
	                 host_ctrl
);

	if_axil vram_lite();

	localparam word
		BOOTROM_MASK   = 32'hfff0_0000,
		DEBUG_BASE     = 32'h0020_0000,
		DEBUG_MASK     = 32'hfff0_0000,
		HOST_CTRL_BASE = 32'h0030_0000,
		HOST_CTRL_MASK = 32'hfff0_0000,
		SHADER_0_BASE  = 32'h0100_0000,
		SHADER_0_MASK  = 32'hfff0_0000,
		VRAM_BASE      = 32'h1c00_0000,
		VRAM_MASK      = 32'hfc00_0000;

	defparam xbar.NM = 1; 
	defparam xbar.NS = 5;
	defparam xbar.OPT_LOWPOWER = 0; 

	defparam xbar.SLAVE_ADDR = {
		VRAM_BASE,
		SHADER_0_BASE,
		HOST_CTRL_BASE,
		DEBUG_BASE,
		BOOTROM_BASE
	};

	defparam xbar.SLAVE_MASK = {
		VRAM_MASK,
		SHADER_0_MASK,
		HOST_CTRL_MASK,
		DEBUG_MASK,
		BOOTROM_MASK
	};

	axilxbar xbar
	(
		.S_AXI_ACLK(clk),
		.S_AXI_ARESETN(srst_n),

		.S_AXI_AWVALID(sched.awvalid),
		.S_AXI_AWREADY(sched.awready),
		.S_AXI_AWADDR(sched.awaddr),
		.S_AXI_AWPROT('0),

		.S_AXI_WVALID(sched.wvalid),
		.S_AXI_WREADY(sched.wready),
		.S_AXI_WDATA(sched.wdata),
		.S_AXI_WSTRB('1),

		.S_AXI_BVALID(sched.bvalid),
		.S_AXI_BREADY(sched.bready),
		.S_AXI_BRESP(),

		.S_AXI_ARVALID(sched.arvalid),
		.S_AXI_ARREADY(sched.arready),
		.S_AXI_ARADDR(sched.araddr),
		.S_AXI_ARPROT('0),

		.S_AXI_RVALID(sched.rvalid),
		.S_AXI_RREADY(sched.rready),
		.S_AXI_RDATA(sched.rdata),
		.S_AXI_RRESP(),

		.M_AXI_AWADDR({
			vram_lite.m.awaddr,
			shader_0.awaddr,
			host_ctrl.awaddr,
			debug.awaddr,
			bootrom.awaddr
		}),
		.M_AXI_AWPROT(),
		.M_AXI_AWVALID({
			vram_lite.m.awvalid,
			shader_0.awvalid,
			host_ctrl.awvalid,
			debug.awvalid,
			bootrom.awvalid
		}),
		.M_AXI_AWREADY({
			vram_lite.m.awready,
			shader_0.awready,
			host_ctrl.awready,
			debug.awready,
			bootrom.awready
		}),

		.M_AXI_WDATA({
			vram_lite.m.wdata,
			shader_0.wdata,
			host_ctrl.wdata,
			debug.wdata,
			bootrom.wdata
		}),
		.M_AXI_WSTRB(),
		.M_AXI_WVALID({
			vram_lite.m.wvalid,
			shader_0.wvalid,
			host_ctrl.wvalid,
			debug.wvalid,
			bootrom.wvalid
		}),
		.M_AXI_WREADY({
			vram_lite.m.wready,
			shader_0.wready,
			host_ctrl.wready,
			debug.wready,
			bootrom.wready
		}),

		.M_AXI_BRESP('0),
		.M_AXI_BVALID({
			vram_lite.m.bvalid,
			shader_0.bvalid,
			host_ctrl.bvalid,
			debug.bvalid,
			bootrom.bvalid
		}),
		.M_AXI_BREADY({
			vram_lite.m.bready,
			shader_0.bready,
			host_ctrl.bready,
			debug.bready,
			bootrom.bready
		}),

		.M_AXI_ARADDR({
			vram_lite.m.araddr,
			shader_0.araddr,
			host_ctrl.araddr,
			debug.araddr,
			bootrom.araddr
		}),
		.M_AXI_ARPROT(),
		.M_AXI_ARVALID({
			vram_lite.m.arvalid,
			shader_0.arvalid,
			host_ctrl.arvalid,
			debug.arvalid,
			bootrom.arvalid
		}),
		.M_AXI_ARREADY({
			vram_lite.m.arready,
			shader_0.arready,
			host_ctrl.arready,
			debug.arready,
			bootrom.arready
		}),

		.M_AXI_RDATA({
			vram_lite.m.rdata,
			shader_0.rdata,
			host_ctrl.rdata,
			debug.rdata,
			bootrom.rdata
		}),
		.M_AXI_RRESP('0),
		.M_AXI_RVALID({
			vram_lite.m.rvalid,
			shader_0.rvalid,
			host_ctrl.rvalid,
			debug.rvalid,
			bootrom.rvalid
		}),
		.M_AXI_RREADY({
			vram_lite.m.rready,
			shader_0.rready,
			host_ctrl.rready,
			debug.rready,
			bootrom.rready
		})
	);

	defparam
		vram_bridge.C_AXI_ID_WIDTH   = 8,
		vram_bridge.C_AXI_ADDR_WIDTH = 32,
		vram_bridge.C_AXI_DATA_WIDTH = 32;

	axilite2axi vram_bridge
	(
		.ACLK(clk),
		.ARESETN(srst_n),

		.S_AXI_AWVALID(vram_lite.s.awvalid),
		.S_AXI_AWREADY(vram_lite.s.awready),
		.S_AXI_AWADDR(vram_lite.s.awaddr),
		.S_AXI_AWPROT(3'b0),
		.S_AXI_WVALID(vram_lite.s.wvalid),
		.S_AXI_WREADY(vram_lite.s.wready),
		.S_AXI_WDATA(vram_lite.s.wdata),
		.S_AXI_WSTRB(4'b1111),
		.S_AXI_BVALID(vram_lite.s.bvalid),
		.S_AXI_BREADY(vram_lite.s.bready),
		.S_AXI_BRESP(),
		.S_AXI_ARVALID(vram_lite.s.arvalid),
		.S_AXI_ARREADY(vram_lite.s.arready),
		.S_AXI_ARADDR(vram_lite.s.araddr),
		.S_AXI_ARPROT(3'b0),
		.S_AXI_RVALID(vram_lite.s.rvalid),
		.S_AXI_RREADY(vram_lite.s.rready),
		.S_AXI_RDATA(vram_lite.s.rdata),
		.S_AXI_RRESP(),

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
		.M_AXI_RLAST(vram.rlast),
		.M_AXI_RRESP(vram.rresp)
	);

endmodule
