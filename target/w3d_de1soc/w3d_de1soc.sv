module w3d_de1soc
(
	input  wire        clk_clk,
	input  wire        rst_n,

	output wire [12:0] memory_mem_a,
	output wire [2:0]  memory_mem_ba,
	output wire        memory_mem_ck,
	output wire        memory_mem_ck_n,
	output wire        memory_mem_cke,
	output wire        memory_mem_cs_n,
	output wire        memory_mem_ras_n,
	output wire        memory_mem_cas_n,
	output wire        memory_mem_we_n,
	output wire        memory_mem_reset_n,
	inout  wire [7:0]  memory_mem_dq,
	inout  wire        memory_mem_dqs,
	inout  wire        memory_mem_dqs_n,
	output wire        memory_mem_odt,
	output wire        memory_mem_dm,
	input  wire        memory_oct_rzqin,
	output wire [7:0]  pio_leds,
	input  wire 	   pio_buttons,
	input  wire [5:0]  pio_switches,
	output wire        vga_dac_clk,
	output wire        vga_dac_hsync,
	output wire        vga_dac_vsync,
	output wire        vga_dac_blank_n,
	output wire        vga_dac_sync_n,
	output wire [7:0]  vga_dac_r,
	output wire [7:0]  vga_dac_g,
	output wire [7:0]  vga_dac_b
);

	// Sistema ve 512MiB superior (0x20000000-0x3fffffff) de SDRAM de HPS
	function logic[31:0] f2s_addr(logic[31:0] addr);
		return {3'b001, addr[28:0]};
	endfunction

	logic button, reset_reset_n, sys_clk, sys_rst_n, sys_srst_n;

	logic dram_arready, dram_arvalid, dram_awready, dram_awvalid, dram_bready, dram_bvalid,
	      dram_rlast, dram_rready, dram_rvalid, dram_wlast, dram_wready, dram_wvalid;

	logic mmio_full_arready, mmio_full_arvalid, mmio_full_awready, mmio_full_awvalid,
	      mmio_full_bready, mmio_full_bvalid, mmio_full_rlast, mmio_full_rready, mmio_full_rvalid,
	      mmio_full_wlast, mmio_full_wready, mmio_full_wvalid;

	logic mmio_arready, mmio_arvalid, mmio_awready, mmio_awvalid,
	      mmio_bready, mmio_bvalid, mmio_rready, mmio_rvalid,
	      mmio_wready, mmio_wvalid;

	logic[1:0] dram_arburst, dram_awburst, dram_bresp, dram_rresp;
	logic[2:0] dram_arsize, dram_awsize;
	logic[3:0] dram_wstrb;
	logic[7:0] dram_arid, dram_arlen, dram_awid, dram_awlen, dram_bid, dram_rid;
	logic[31:0] dram_araddr, dram_awaddr, dram_rdata, dram_wdata;

	logic[7:0] mmio_full_arid, mmio_full_arlen, mmio_full_awid, mmio_full_awlen,
	           mmio_full_bid, mmio_full_rid;

	logic[1:0] mmio_full_arburst, mmio_full_awburst, mmio_full_bresp, mmio_full_rresp;
	logic[2:0] mmio_full_arsize, mmio_full_awsize;
	logic[3:0] mmio_full_arqos, mmio_full_awqos, mmio_full_wstrb;
	logic[31:0] mmio_full_araddr, mmio_full_awaddr, mmio_full_rdata, mmio_full_wdata;

	logic[3:0] mmio_wstrb;
	logic[31:0] mmio_araddr, mmio_awaddr, mmio_rdata, mmio_wdata;

	logic mmio_full_arlock, mmio_full_awlock;
	logic[2:0] mmio_full_arprot, mmio_full_awprot;
	logic[3:0] mmio_full_arcache, mmio_full_awcache;

	logic dac_first, dac_last, dac_ready, dac_valid;
	logic[9:0] dac_r, dac_g, dac_b;

	debounce reset_debounce
	(
		.clk(sys_clk),
		.dirty(rst_n),
		.clean(reset_reset_n)
	);

	debounce button_debounce
	(
		.clk(sys_clk),
		.dirty(pio_buttons),
		.clean(button)
	);

	platform plat
	(
		//FIXME: el glitch de reset
		.clk_clk,
		.reset_reset_n,
		.pll_0_reset_reset(0), //TODO: reset controller, algún día
		.memory_mem_a,
		.memory_mem_ba,
		.memory_mem_ck,
		.memory_mem_ck_n,
		.memory_mem_cke,
		.memory_mem_cs_n,
		.memory_mem_ras_n,
		.memory_mem_cas_n,
		.memory_mem_we_n,
		.memory_mem_reset_n,
		.memory_mem_dq,
		.memory_mem_dqs,
		.memory_mem_dqs_n,
		.memory_mem_odt,
		.memory_mem_dm,
		.memory_oct_rzqin,
		.pio_0_external_connection_export(pio_leds),
		.buttons_external_connection_export({7'b0000000, !button}),
		.switches_external_connection_export({2'b00, pio_switches}),
		.vga_dac_CLK(vga_dac_clk),
		.vga_dac_HS(vga_dac_hsync),
		.vga_dac_VS(vga_dac_vsync),
		.vga_dac_BLANK(vga_dac_blank_n),
		.vga_dac_SYNC(vga_dac_sync_n),
		.vga_dac_R(vga_dac_r),
		.vga_dac_G(vga_dac_g),
		.vga_dac_B(vga_dac_b),
		.dram_axi_bridge_s0_araddr(f2s_addr(dram_araddr)),
		.dram_axi_bridge_s0_arlen(dram_arlen),
		.dram_axi_bridge_s0_arid(dram_arid),
		.dram_axi_bridge_s0_arsize(dram_arsize),
		.dram_axi_bridge_s0_arburst(dram_arburst),
		.dram_axi_bridge_s0_arvalid(dram_arvalid),
		.dram_axi_bridge_s0_awaddr(f2s_addr(dram_awaddr)),
		.dram_axi_bridge_s0_awlen(dram_awlen),
		.dram_axi_bridge_s0_awid(dram_awid),
		.dram_axi_bridge_s0_awsize(dram_awsize),
		.dram_axi_bridge_s0_awburst(dram_awburst),
		.dram_axi_bridge_s0_awvalid(dram_awvalid),
		.dram_axi_bridge_s0_bresp(dram_bresp),
		.dram_axi_bridge_s0_bid(dram_bid),
		.dram_axi_bridge_s0_bvalid(dram_bvalid),
		.dram_axi_bridge_s0_bready(dram_bready),
		.dram_axi_bridge_s0_arready(dram_arready),
		.dram_axi_bridge_s0_awready(dram_awready),
		.dram_axi_bridge_s0_rready(dram_rready),
		.dram_axi_bridge_s0_rdata(dram_rdata),
		.dram_axi_bridge_s0_rresp(dram_rresp),
		.dram_axi_bridge_s0_rlast(dram_rlast),
		.dram_axi_bridge_s0_rid(dram_rid),
		.dram_axi_bridge_s0_rvalid(dram_rvalid),
		.dram_axi_bridge_s0_wlast(dram_wlast),
		.dram_axi_bridge_s0_wvalid(dram_wvalid),
		.dram_axi_bridge_s0_wdata(dram_wdata),
		.dram_axi_bridge_s0_wstrb(dram_wstrb),
		.dram_axi_bridge_s0_wready(dram_wready),
		.io_axi_bridge_s0_awid(mmio_full_awid),
		.io_axi_bridge_s0_awaddr(mmio_full_awaddr),
		.io_axi_bridge_s0_awlen(mmio_full_awlen),
		.io_axi_bridge_s0_awsize(mmio_full_awsize),
		.io_axi_bridge_s0_awburst(mmio_full_awburst),
		.io_axi_bridge_s0_awlock(mmio_full_awlock),
		.io_axi_bridge_s0_awcache(mmio_full_awcache),
		.io_axi_bridge_s0_awprot(mmio_full_awprot),
		.io_axi_bridge_s0_awqos(mmio_full_awqos),
		.io_axi_bridge_s0_awregion(4'b0),
		.io_axi_bridge_s0_awvalid(mmio_full_awvalid),
		.io_axi_bridge_s0_awready(mmio_full_awready),
		.io_axi_bridge_s0_wdata(mmio_full_wdata),
		.io_axi_bridge_s0_wstrb(mmio_full_wstrb),
		.io_axi_bridge_s0_wlast(mmio_full_wlast),
		.io_axi_bridge_s0_wvalid(mmio_full_wvalid),
		.io_axi_bridge_s0_wready(mmio_full_wready),
		.io_axi_bridge_s0_bid(mmio_full_bid),
		.io_axi_bridge_s0_bresp(mmio_full_bresp),
		.io_axi_bridge_s0_bvalid(mmio_full_bvalid),
		.io_axi_bridge_s0_bready(mmio_full_bready),
		.io_axi_bridge_s0_arid(mmio_full_arid),
		.io_axi_bridge_s0_araddr(mmio_full_araddr),
		.io_axi_bridge_s0_arlen(mmio_full_arlen),
		.io_axi_bridge_s0_arsize(mmio_full_arsize),
		.io_axi_bridge_s0_arburst(mmio_full_arburst),
		.io_axi_bridge_s0_arlock(mmio_full_arlock),
		.io_axi_bridge_s0_arcache(mmio_full_arcache),
		.io_axi_bridge_s0_arprot(mmio_full_arprot),
		.io_axi_bridge_s0_arqos(mmio_full_arqos),
		.io_axi_bridge_s0_arregion(4'b0),
		.io_axi_bridge_s0_arvalid(mmio_full_arvalid),
		.io_axi_bridge_s0_arready(mmio_full_arready),
		.io_axi_bridge_s0_rid(mmio_full_rid),
		.io_axi_bridge_s0_rdata(mmio_full_rdata),
		.io_axi_bridge_s0_rresp(mmio_full_rresp),
		.io_axi_bridge_s0_rlast(mmio_full_rlast),
		.io_axi_bridge_s0_rvalid(mmio_full_rvalid),
		.io_axi_bridge_s0_rready(mmio_full_rready),
		.intc_0_interrupt_sender_irq(), //TODO
		.pixfifo_avalon_dc_buffer_sink_ready(dac_ready),
		.pixfifo_avalon_dc_buffer_sink_startofpacket(dac_first),
		.pixfifo_avalon_dc_buffer_sink_endofpacket(dac_last),
		.pixfifo_avalon_dc_buffer_sink_valid(dac_valid),
		.pixfifo_avalon_dc_buffer_sink_data({dac_r, dac_g, dac_b}),
		.sys_clock_out_clk_1_clk(sys_clk),
		.sys_rst_out_reset_1_reset_n(sys_rst_n)
	);

	w3d_top w3d
	(
		.clk(sys_clk),
		.rst_n(sys_rst_n),
		.srst_n(sys_srst_n), // output

		.dram_awvalid,
		.dram_awready,
		.dram_awid,
		.dram_awlen,
		.dram_awsize,
		.dram_awburst,
		.dram_awaddr,
		.dram_wvalid,
		.dram_wready,
		.dram_wdata,
		.dram_wlast,
		.dram_wstrb,
		.dram_bvalid,
		.dram_bready,
		.dram_bid,
		.dram_bresp,
		.dram_arvalid,
		.dram_arready,
		.dram_arid,
		.dram_arlen,
		.dram_arsize,
		.dram_arburst,
		.dram_araddr,
		.dram_rvalid,
		.dram_rready,
		.dram_rid,
		.dram_rdata,
		.dram_rresp,
		.dram_rlast,

		.mmio_awvalid,
		.mmio_awready,
		.mmio_awaddr,
		.mmio_wvalid,
		.mmio_wready,
		.mmio_wdata,
		.mmio_bvalid,
		.mmio_bready,
		.mmio_arvalid,
		.mmio_arready,
		.mmio_araddr,
		.mmio_rvalid,
		.mmio_rready,
		.mmio_rdata,

		.dac_b,
		.dac_g,
		.dac_r,
		.dac_last,
		.dac_first,
		.dac_ready,
		.dac_valid,

		//TODO Altera Virtual JTAG
		.jtag_tck(0),
		.jtag_tms(0),
		.jtag_tdi(0),
		.jtag_tdo()
	);

	defparam
		mmio_bridge.C_AXI_ID_WIDTH   = 8,
		mmio_bridge.C_AXI_ADDR_WIDTH = 32,
		mmio_bridge.C_AXI_DATA_WIDTH = 32;

	axilite2axi mmio_bridge
	(
		.ACLK(sys_clk),
		.ARESETN(sys_srst_n),

		.S_AXI_AWVALID(mmio_awvalid),
		.S_AXI_AWREADY(mmio_awready),
		.S_AXI_AWADDR(mmio_awaddr),
		.S_AXI_AWPROT(3'b0),
		.S_AXI_WVALID(mmio_wvalid),
		.S_AXI_WREADY(mmio_wready),
		.S_AXI_WDATA(mmio_wdata),
		.S_AXI_WSTRB(4'b1111),
		.S_AXI_BVALID(mmio_bvalid),
		.S_AXI_BREADY(mmio_bready),
		.S_AXI_BRESP(),
		.S_AXI_ARVALID(mmio_arvalid),
		.S_AXI_ARREADY(mmio_arready),
		.S_AXI_ARADDR(mmio_araddr),
		.S_AXI_ARPROT(3'b0),
		.S_AXI_RVALID(mmio_rvalid),
		.S_AXI_RREADY(mmio_rready),
		.S_AXI_RDATA(mmio_rdata),
		.S_AXI_RRESP(),

		.M_AXI_AWVALID(mmio_full_awvalid),
		.M_AXI_AWREADY(mmio_full_awready),
		.M_AXI_AWID(mmio_full_awid),
		.M_AXI_AWADDR(mmio_full_awaddr),
		.M_AXI_AWLEN(mmio_full_awlen),
		.M_AXI_AWSIZE(mmio_full_awsize),
		.M_AXI_AWBURST(mmio_full_awburst),
		.M_AXI_AWLOCK(mmio_full_awlock),
		.M_AXI_AWCACHE(mmio_full_awcache),
		.M_AXI_AWPROT(mmio_full_awprot),
		.M_AXI_AWQOS(mmio_full_awqos),
		.M_AXI_WVALID(mmio_full_wvalid),
		.M_AXI_WREADY(mmio_full_wready),
		.M_AXI_WDATA(mmio_full_wdata),
		.M_AXI_WSTRB(mmio_full_wstrb),
		.M_AXI_WLAST(mmio_full_wlast),
		.M_AXI_BVALID(mmio_full_bvalid),
		.M_AXI_BREADY(mmio_full_bready),
		.M_AXI_BID(mmio_full_bid),
		.M_AXI_BRESP(mmio_full_bresp),
		.M_AXI_ARVALID(mmio_full_arvalid),
		.M_AXI_ARREADY(mmio_full_arready),
		.M_AXI_ARID(mmio_full_arid),
		.M_AXI_ARADDR(mmio_full_araddr),
		.M_AXI_ARLEN(mmio_full_arlen),
		.M_AXI_ARSIZE(mmio_full_arsize),
		.M_AXI_ARBURST(mmio_full_arburst),
		.M_AXI_ARLOCK(mmio_full_arlock),
		.M_AXI_ARCACHE(mmio_full_arcache),
		.M_AXI_ARPROT(mmio_full_arprot),
		.M_AXI_ARQOS(mmio_full_arqos),
		.M_AXI_RVALID(mmio_full_rvalid),
		.M_AXI_RREADY(mmio_full_rready),
		.M_AXI_RID(mmio_full_rid),
		.M_AXI_RDATA(mmio_full_rdata),
		.M_AXI_RLAST(mmio_full_rlast),
		.M_AXI_RRESP(mmio_full_rresp)
	);

endmodule
