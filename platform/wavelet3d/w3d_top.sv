module w3d_top
import gfx::*;
(
	input  logic clk,
	             rst_n,

	input  word  a[SHADER_LANES],
	             b[SHADER_LANES],
	input  logic in_valid,
	             setup_mul_float,
	             setup_unit_b,
	             mnorm_put_hi,
	             mnorm_put_lo,
	             mnorm_put_mul,
	             mnorm_zero_b,
	             mnorm_zero_flags,
	             minmax_abs,
	             minmax_swap,
	             minmax_zero_min,
	             minmax_copy_flags,
	             shiftr_int_signed,
	             addsub_copy_flags,
	             addsub_int_operand,
	             clz_force_nop,
	             shiftl_copy_flags,
	             round_copy_flags,
	             round_enable,
	             encode_enable,

	output logic out_valid,
	output word  q[SHADER_LANES],

	input  word  geom_tdata,
	input  logic geom_tlast,
	             geom_tvalid,
	output logic geom_tready,

	input  logic raster_tready,
	output logic raster_tlast,
	             raster_tvalid,
	output word  raster_tdata
);

	gfx_wb fpint_wb();
	if_tap host_jtag();
	if_axib dram(), host_dbus(), host_ibus();
	if_axil external_io(), gfx_ctrl();
	if_pkts coverage(), geometry();
	gfx_regfile_io fpint_io();

	logic srst_n;

	assign q = fpint_wb.rx.lanes;
	assign out_valid = fpint_wb.rx.valid;

	assign geometry.tx.tdata = geom_tdata;
	assign geometry.tx.tlast = geom_tlast;
	assign geometry.tx.tvalid = geom_tvalid;
	assign geom_tready = geometry.tx.tready;

	assign raster_tdata = coverage.rx.tdata;
	assign raster_tlast = coverage.rx.tlast;
	assign raster_tvalid = coverage.rx.tvalid;
	assign coverage.rx.tready = raster_tready;

	fpint_op op;
	assign op.writeback = 1;
	assign op.setup_mul_float = setup_mul_float;
	assign op.setup_unit_b = setup_unit_b;
	assign op.mnorm_put_hi = mnorm_put_hi;
	assign op.mnorm_put_lo = mnorm_put_lo;
	assign op.mnorm_put_mul = mnorm_put_mul;
	assign op.mnorm_zero_b = mnorm_zero_b;
	assign op.mnorm_zero_flags = mnorm_zero_flags;
	assign op.minmax_abs = minmax_abs;
	assign op.minmax_swap = minmax_swap;
	assign op.minmax_zero_min = minmax_zero_min;
	assign op.minmax_copy_flags = minmax_copy_flags;
	assign op.shiftr_int_signed = shiftr_int_signed;
	assign op.addsub_copy_flags = addsub_copy_flags;
	assign op.addsub_int_operand = addsub_int_operand;
	assign op.clz_force_nop = clz_force_nop;
	assign op.shiftl_copy_flags = shiftl_copy_flags;
	assign op.round_copy_flags = round_copy_flags;
	assign op.round_enable = round_enable;
	assign op.encode_enable = encode_enable;

	assign fpint_io.regs.a = a;
	assign fpint_io.regs.b = b;

	if_rst_sync rst_sync
	(
		.clk,
		.rst_n,
		.srst_n
	);

	gfx_shader_fpint fpint
	(
		.clk,
		.rst_n,
		.op,
		.wb(fpint_wb.tx),
		.wave(),
		.abort(0),
		.in_valid,
		.read_data(fpint_io.ab)
	);

	gfx_raster raster
	(
		.clk,
		.rst_n,
		.geometry(geometry.rx),
		.coverage(coverage.tx)
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
