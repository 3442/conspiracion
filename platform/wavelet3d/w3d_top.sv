module w3d_top
(
	input  logic clk,
	             rst_n,

	input  logic jtag_tck,
	             jtag_tms,
	             jtag_tdi,

	output logic jtag_tdo
);

	if_tap host_jtag();
	if_axib dram(), host_dbus(), host_ibus();
	if_axil external_io(), gfx_ctrl();

	logic srst_n;

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
