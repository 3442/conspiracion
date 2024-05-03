module gfx_shader
import gfx::*;
import gfx_shader_schedif_pkg::*;
(
	input  logic      clk,
	                  rst_n,

	       gfx_axib.m insn_mem,

	       gfx_axil.s sched
);

	axi4lite_intf #(.ADDR_WIDTH(4)) regblock();

	gfx_axil2regblock axil2regblock
	(
		.axis(sched),
		.axim(regblock.master)
	);

	gfx_shader_schedif__in_t schedif_in;
	gfx_shader_schedif__out_t schedif_out;

	gfx_front_back front_back();
	gfx_regfile_io regfile();

	gfx_shader_front frontend
	(
		.clk,
		.rst_n,
		.front(front_back.front),
		.reg_bind(regfile.bind_),
		.reg_read(regfile.read),
		.fetch_mem(insn_mem),
		.icache_flush(schedif_out.CORE.IFLUSH.value)
	);

	gfx_shader_back backend
	(
		.clk,
		.rst_n,
		.back(front_back.back),
		.reg_wb(regfile.wb),
		.read_data(regfile.ab)
	);

	gfx_shader_regs regs
	(
		.clk,
		.io(regfile)
	);

	gfx_shader_schedif schedif
	(
		.clk,
		.arst_n(rst_n),
		.s_axil(regblock.slave),
		.hwif_in(schedif_in),
		.hwif_out(schedif_out)
	);

endmodule
