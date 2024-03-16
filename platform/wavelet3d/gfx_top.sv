module gfx_top
(
	input  logic     clk,
	                 rst_n,

	input  gfx::word a[gfx::SHADER_LANES],
	                 b[gfx::SHADER_LANES],
	input logic      in_valid,
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

	output logic     out_valid,
	output gfx::word q[gfx::SHADER_LANES],

	input  gfx::word geom_tdata,
	input  logic     geom_tlast,
	                 geom_tvalid,
	output logic     geom_tready,

	input  logic     raster_tready,
	output logic     raster_tlast,
	                 raster_tvalid,
	output gfx::word raster_tdata
);

	gfx_axil sched_axi();
	gfx_pkts geometry(), coverage();

	assign geometry.tdata = geom_tdata;
	assign geometry.tlast = geom_tlast;
	assign geometry.tvalid = geom_tvalid;
	assign geom_tready = geometry.tready;

	assign raster_tdata = coverage.tdata;
	assign raster_tlast = coverage.tlast;
	assign raster_tvalid = coverage.tvalid;
	assign coverage.tready = raster_tready;

	gfx_fpint fpint
	(
		.*
	);

	gfx_sched sched
	(
		.clk,
		.rst_n,
		.irq(0),
		.axim(sched_axi.m)
	);

	gfx_raster raster
	(
		.clk,
		.rst_n,
		.geometry(coverage.rx),
		.coverage(coverage.tx)
	);

endmodule
