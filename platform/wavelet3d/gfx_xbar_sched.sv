module gfx_xbar_sched
import gfx::*;
(
	input  logic      clk,
	                  srst_n,

	       gfx_axil.s sched,

	       gfx_axil.m debug,
	       gfx_axil.m bootrom,
	       gfx_axil.m shader_0
);

	localparam word BOOTROM_MASK  = 32'hfff0_0000;
	localparam word DEBUG_BASE    = 32'h0020_0000;
	localparam word DEBUG_MASK    = 32'hfff0_0000;
	localparam word SHADER_0_BASE = 32'h0100_0000;
	localparam word SHADER_0_MASK = 32'hfff0_0000;

	defparam xbar.NM = 1; 
	defparam xbar.NS = 3;
	defparam xbar.OPT_LOWPOWER = 0; 

	defparam xbar.SLAVE_ADDR = {
		SHADER_0_BASE,
		DEBUG_BASE,
		BOOTROM_BASE
	};

	defparam xbar.SLAVE_MASK = {
		SHADER_0_MASK,
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
			shader_0.awaddr,
			debug.awaddr,
			bootrom.awaddr
		}),
		.M_AXI_AWPROT(),
		.M_AXI_AWVALID({
			shader_0.awvalid,
			debug.awvalid,
			bootrom.awvalid
		}),
		.M_AXI_AWREADY({
			shader_0.awready,
			debug.awready,
			bootrom.awready
		}),

		.M_AXI_WDATA({
			shader_0.wdata,
			debug.wdata,
			bootrom.wdata
		}),
		.M_AXI_WSTRB(),
		.M_AXI_WVALID({
			shader_0.wvalid,
			debug.wvalid,
			bootrom.wvalid
		}),
		.M_AXI_WREADY({
			shader_0.wready,
			debug.wready,
			bootrom.wready
		}),

		.M_AXI_BRESP('0),
		.M_AXI_BVALID({
			shader_0.bvalid,
			debug.bvalid,
			bootrom.bvalid
		}),
		.M_AXI_BREADY({
			shader_0.bready,
			debug.bready,
			bootrom.bready
		}),

		.M_AXI_ARADDR({
			shader_0.araddr,
			debug.araddr,
			bootrom.araddr
		}),
		.M_AXI_ARPROT(),
		.M_AXI_ARVALID({
			shader_0.arvalid,
			debug.arvalid,
			bootrom.arvalid
		}),
		.M_AXI_ARREADY({
			shader_0.arready,
			debug.arready,
			bootrom.arready
		}),

		.M_AXI_RDATA({
			shader_0.rdata,
			debug.rdata,
			bootrom.rdata
		}),
		.M_AXI_RRESP('0),
		.M_AXI_RVALID({
			shader_0.rvalid,
			debug.rvalid,
			bootrom.rvalid
		}),
		.M_AXI_RREADY({
			shader_0.rready,
			debug.rready,
			bootrom.rready
		})
	);

endmodule
