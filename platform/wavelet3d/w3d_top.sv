module w3d_top
(
	input  logic       clk,
	                   rst_n,

	output logic       dram_awvalid,
	input  logic       dram_awready,
	output logic[7:0]  dram_awid,
	output logic[7:0]  dram_awlen,
	output logic[2:0]  dram_awsize,
	output logic[1:0]  dram_awburst,
	output logic[31:0] dram_awaddr,

	output logic       dram_wvalid,
	input  logic       dram_wready,
	output logic[31:0] dram_wdata,
	output logic       dram_wlast,
	output logic[3:0]  dram_wstrb,

	input  logic       dram_bvalid,
	output logic       dram_bready,
	input  logic[7:0]  dram_bid,
	input  logic[1:0]  dram_bresp,

	output logic       dram_arvalid,
	input  logic       dram_arready,
	output logic[7:0]  dram_arid,
	output logic[7:0]  dram_arlen,
	output logic[2:0]  dram_arsize,
	output logic[1:0]  dram_arburst,
	output logic[31:0] dram_araddr,

	input  logic       dram_rvalid,
	output logic       dram_rready,
	input  logic[7:0]  dram_rid,
	input  logic[31:0] dram_rdata,
	input  logic[1:0]  dram_rresp,
	input  logic       dram_rlast,

	input  logic       jtag_tck,
	                   jtag_tms,
	                   jtag_tdi,
	output logic       jtag_tdo
);

	if_tap host_jtag();
	if_axib dram(), host_dbus(), host_ibus();
	if_axil external_io(), gfx_ctrl();

	logic srst_n;

	assign dram_awid = dram.s.awid;
	assign dram_awlen = dram.s.awlen;
	assign dram_awaddr = dram.s.awaddr;
	assign dram_awsize = dram.s.awsize;
	assign dram_awburst = dram.s.awburst;
	assign dram_awvalid = dram.s.awvalid;
	assign dram.s.awready = dram_awready;

	assign dram_wdata = dram.s.wdata;
	assign dram_wlast = dram.s.wlast;
	assign dram_wstrb = dram.s.wstrb;
	assign dram_wvalid = dram.s.wvalid;
	assign dram.s.wready = dram_wready;

	assign dram_bready = dram.s.bready;
	assign dram.s.bid = dram_bid;
	assign dram.s.bresp = dram_bresp;
	assign dram.s.bvalid = dram_bvalid;

	assign dram_arid = dram.s.arid;
	assign dram_arlen = dram.s.arlen;
	assign dram_araddr = dram.s.araddr;
	assign dram_arsize = dram.s.arsize;
	assign dram_arburst = dram.s.arburst;
	assign dram_arvalid = dram.s.arvalid;
	assign dram.s.arready = dram_arready;

	assign dram_rready = dram.s.rready;
	assign dram.s.rid = dram_rid;
	assign dram.s.rdata = dram_rdata;
	assign dram.s.rlast = dram_rlast;
	assign dram.s.rresp = dram_rresp;
	assign dram.s.rvalid = dram_rvalid;

	assign jtag_tdo = host_jtag.m.tdo;
	assign host_jtag.m.tck = jtag_tck;
	assign host_jtag.m.tms = jtag_tms;
	assign host_jtag.m.tdi = jtag_tdi;

	if_rst_sync rst_sync
	(
		.clk,
		.rst_n,
		.srst_n
	);

	gfx_top gfx
	(
		.clk,
		.rst_n,
		.srst_n,
		.host_ctrl(gfx_ctrl.s)
	);

	w3d_host host
	(
		.clk,
		.rst_n,
		.dbus(host_dbus.m),
		.ibus(host_ibus.m),
		.jtag(host_jtag.s)
	);

	w3d_interconnect inter
	(
		.clk,
		.srst_n,
		.dram(dram.m),
		.gfx_ctrl(gfx_ctrl.m),
		.host_dbus(host_dbus.s),
		.host_ibus(host_ibus.s),
		.external_io(external_io.m)
	);

endmodule
