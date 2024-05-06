module gfx_shader
import gfx::*;
import gfx_shader_schedif_pkg::*;
(
	input  logic     clk,
	                 rst_n,

	       if_axib.m insn_mem,

	       if_axil.s sched
);

	axi4lite_intf #(.ADDR_WIDTH(GFX_SHADER_SCHEDIF_MIN_ADDR_WIDTH)) regblock();

	if_axil2regblock axil2regblock
	(
		.axis(sched),
		.axim(regblock.master)
	);

	gfx_shader_schedif__in_t schedif_in;
	gfx_shader_schedif__out_t schedif_out;

	gfx_front_back front_back();
	gfx_regfile_io regfile();
	gfx_shader_setup setup();

	assign schedif_in.SETUP_CTRL.GPR_DONE.hwset = setup.sched.set_done.gpr;
	assign schedif_in.SETUP_CTRL.MASK_DONE.hwset = setup.sched.set_done.mask;
	assign schedif_in.SETUP_CTRL.SUBMIT_DONE.hwset = setup.sched.set_done.submit;

	assign setup.sched.write.pc = schedif_out.SETUP_SUBMIT.PC.value;
	assign setup.sched.write.gpr = schedif_out.SETUP_CTRL.XGPR.value;
	assign setup.sched.write.mask = schedif_out.SETUP_MASK.MASK.value;
	assign setup.sched.write.group = schedif_out.SETUP_CTRL.GROUP.value;
	assign setup.sched.write.pc_set = schedif_out.SETUP_SUBMIT.PC.swmod;
	assign setup.sched.write.gpr_set = schedif_out.SETUP_GPR.VALUE.swmod;
	assign setup.sched.write.mask_set = schedif_out.SETUP_MASK.MASK.swmod;
	assign setup.sched.write.gpr_value = schedif_out.SETUP_GPR.VALUE.value;

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
		.setup(setup.core),
		.reg_wb(regfile.wb),
		.read_data(regfile.ab)
	);

	gfx_shader_regs regs
	(
		.clk,
		.io(regfile.regs)
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
