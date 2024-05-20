module gfx_top
import gfx::*;
(
	input  logic     clk,
	                 rst_n,
	                 srst_n,
	
	       if_axib.m vram,

	       if_axil.s host_ctrl
);

	if_axib data_mem(), insn_mem();
	if_axil bootrom_axi(), debug_axi(), host_ctrl_axi(), sched_axi(), shader_0_axi();

	logic irq_host_ctrl;
	irq_lines irq;

	gfx_sched sched
	(
		.clk,
		.rst_n,
		.srst_n,
		.irq,
		.axim(sched_axi.m)
	);

	axilemu host_ctrl_bridge
	(
		.clk,
		.rst_n,
		.irq(irq_host_ctrl),
		.agent(host_ctrl),
		.driver(host_ctrl_axi.s)
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
		.data_mem(data_mem.m),
		.insn_mem(insn_mem.m)
	);

	gfx_xbar_sched sched_xbar
	(
		.clk,
		.srst_n,

		.sched(sched_axi.s),

		.debug(debug_axi.m),
		.bootrom(bootrom_axi.m),
		.shader_0(shader_0_axi.m),
		.host_ctrl(host_ctrl_axi.m)
	);

	gfx_xbar_vram vram_xbar
	(
		.clk,
		.srst_n,
		.vram,
		.shader_0_data(data_mem.s),
		.shader_0_insn(insn_mem.s)
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

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			irq <= '0;
		else begin
			irq <= '0;
			irq[0] <= irq_host_ctrl;
		end

endmodule
