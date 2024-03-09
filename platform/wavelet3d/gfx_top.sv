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
	output gfx::word q[gfx::SHADER_LANES]
);

	gfx_axil sched_axi();

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

endmodule
