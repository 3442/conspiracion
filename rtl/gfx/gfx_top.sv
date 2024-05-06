module gfx_top
import gfx::*;
(
	input  logic clk,
	             rst_n
);

	logic srst_n;

	if_axib insn_mem();
	if_axil bootrom_axi(), debug_axi(), sched_axi(), shader_0_axi();

	gfx_rst_sync rst_sync
	(
		.clk,
		.rst_n,
		.srst_n
	);

	gfx_sched sched
	(
		.clk,
		.rst_n,
		.srst_n,
		.irq(0),
		.axim(sched_axi.m)
	);

	gfx_bootrom bootrom
	(
		.clk,
		.rst_n,
		.axis(bootrom_axi.s)
	);

	gfx_sim_debug debug
	(
		.clk,
		.rst_n,
		.axis(debug_axi.s)
	);

	gfx_shader shader_0
	(
		.clk,
		.rst_n,
		.sched(shader_0_axi.s),
		.insn_mem(insn_mem.m)
	);

	gfx_xbar_sched xbar
	(
		.clk,
		.srst_n,

		.sched(sched_axi.s),

		.debug(debug_axi.m),
		.bootrom(bootrom_axi.m),
		.shader_0(shader_0_axi.m)
	);

	/*TODO
	gfx_raster raster
	(
		.clk,
		.rst_n,
		.geometry(TODO),
		.coverage(TODO)
	);
	*/

endmodule
