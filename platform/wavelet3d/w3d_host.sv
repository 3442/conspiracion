module w3d_host
(
	input  logic     clk,
	                 rst_n,

	       if_axib.m dbus,
	                 ibus
);

	assign dbus.arid = '0;
	assign dbus.awid = '0;

	w3d_host_vexriscv cpu
	(
		.clk,
		.resetn(rst_n),

		//TODO
		.timerInterrupt(0),
		.externalInterrupt(0),
		.softwareInterrupt(0),

		.iBusAxi_ar_valid(ibus.arvalid),
		.iBusAxi_ar_ready(ibus.arready),
		.iBusAxi_ar_payload_addr(ibus.araddr),
		.iBusAxi_ar_payload_id(),
		.iBusAxi_ar_payload_region(),
		.iBusAxi_ar_payload_len(ibus.arlen),
		.iBusAxi_ar_payload_size(ibus.arsize),
		.iBusAxi_ar_payload_burst(ibus.arburst),
		.iBusAxi_ar_payload_lock(),
		.iBusAxi_ar_payload_cache(),
		.iBusAxi_ar_payload_qos(),
		.iBusAxi_ar_payload_prot(),

		.iBusAxi_r_valid(ibus.rvalid),
		.iBusAxi_r_ready(ibus.rready),
		.iBusAxi_r_payload_data(ibus.rdata),
		.iBusAxi_r_payload_id('0),
		.iBusAxi_r_payload_resp(ibus.rresp),
		.iBusAxi_r_payload_last(ibus.rlast),

		.dBusAxi_aw_valid(dbus.awvalid),
		.dBusAxi_aw_ready(dbus.awready),
		.dBusAxi_aw_payload_addr(dbus.awaddr),
		.dBusAxi_aw_payload_id(),
		.dBusAxi_aw_payload_region(),
		.dBusAxi_aw_payload_len(dbus.awlen),
		.dBusAxi_aw_payload_size(dbus.awsize),
		.dBusAxi_aw_payload_burst(dbus.awburst),
		.dBusAxi_aw_payload_lock(),
		.dBusAxi_aw_payload_cache(),
		.dBusAxi_aw_payload_qos(),
		.dBusAxi_aw_payload_prot(),

		.dBusAxi_w_valid(dbus.wvalid),
		.dBusAxi_w_ready(dbus.wready),
		.dBusAxi_w_payload_data(dbus.wdata),
		.dBusAxi_w_payload_strb(dbus.wstrb),
		.dBusAxi_w_payload_last(dbus.wlast),

		.dBusAxi_b_valid(dbus.bvalid),
		.dBusAxi_b_ready(dbus.bready),
		.dBusAxi_b_payload_id('0),
		.dBusAxi_b_payload_resp(dbus.bresp),

		.dBusAxi_ar_valid(dbus.arvalid),
		.dBusAxi_ar_ready(dbus.arready),
		.dBusAxi_ar_payload_addr(dbus.araddr),
		.dBusAxi_ar_payload_id(),
		.dBusAxi_ar_payload_region(),
		.dBusAxi_ar_payload_len(dbus.arlen),
		.dBusAxi_ar_payload_size(dbus.arsize),
		.dBusAxi_ar_payload_burst(dbus.arburst),
		.dBusAxi_ar_payload_lock(),
		.dBusAxi_ar_payload_cache(),
		.dBusAxi_ar_payload_qos(),
		.dBusAxi_ar_payload_prot(),

		.dBusAxi_r_valid(dbus.rvalid),
		.dBusAxi_r_ready(dbus.rready),
		.dBusAxi_r_payload_data(dbus.rdata),
		.dBusAxi_r_payload_id('0),
		.dBusAxi_r_payload_resp(dbus.rresp),
		.dBusAxi_r_payload_last(dbus.rlast)
	);

endmodule
