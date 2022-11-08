`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word        insn,
	input  psr_flags   flags,

	output insn_decode dec
);

	mul_decode mul_ctrl;
	psr_decode psr_ctrl;
	snd_decode snd_ctrl;
	data_decode data_ctrl;
	ldst_decode ldst_ctrl;
	branch_decode branch_ctrl;
	coproc_decode coproc_ctrl;
	datapath_decode ctrl;

	assign dec.mul = mul_ctrl;
	assign dec.psr = psr_ctrl;
	assign dec.snd = snd_ctrl;
	assign dec.ctrl = ctrl;
	assign dec.data = data_ctrl;
	assign dec.ldst = ldst_ctrl;
	assign dec.branch = branch_ctrl;
	assign dec.coproc = coproc_ctrl;

	assign ctrl.execute = execute;
	assign ctrl.undefined = undefined;
	assign ctrl.conditional = conditional;
	assign ctrl.writeback = writeback;
	assign ctrl.branch = branch;
	assign ctrl.coproc = coproc;
	assign ctrl.ldst = ldst;
	assign ctrl.mul = mul;

	assign psr_ctrl.saved = spsr;
	assign psr_ctrl.write = psr_write;
	assign psr_ctrl.update_flags = update_flags;

	logic execute, undefined, conditional, writeback, update_flags,
	      branch, ldst, mul, coproc, spsr, psr_write;

	core_decode_mux mux
	(
		.*
	);

	//TODO
	logic restore_spsr;

	logic cond_undefined, cond_execute, explicit_cond;

	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.execute(cond_execute),
		.undefined(cond_undefined),
		.conditional(explicit_cond),
		.*
	);

	logic snd_is_imm, snd_ror_if_imm, snd_shift_by_reg_if_reg, snd_undefined;
	snd_decode snd;

	core_decode_snd snd_operand
	(
		.decode(snd),
		.is_imm(snd_is_imm),
		.ror_if_imm(snd_ror_if_imm),
		.shift_by_reg_if_reg(snd_shift_by_reg_if_reg),
		.undefined(snd_undefined),
		.*
	);

	logic branch_link;

	core_decode_branch group_branch
	(
		.link(branch_link),
		.offset(branch_ctrl.offset),
		.*
	);

	data_decode data;
	logic data_writeback, data_update_flags, data_restore_spsr,
	      data_is_imm, data_shift_by_reg_if_reg, data_conditional;

	core_decode_data group_data
	(
		.decode(data),
		.writeback(data_writeback),
		.conditional(data_conditional),
		.update_flags(data_update_flags),
		.restore_spsr(data_restore_spsr),
		.snd_is_imm(data_is_imm),
		.snd_shift_by_reg_if_reg(data_shift_by_reg_if_reg),
		.*
	);

	logic ldst_single_is_imm;
	ldst_decode ldst_single;

	core_decode_ldst_single group_ldst_single
	(
		.snd_is_imm(ldst_single_is_imm),
		.decode(ldst_single),
		.*
	);

	ldst_decode ldst_misc;
	logic ldst_misc_off_is_reg;
	reg_num ldst_misc_off_reg;
	logic[7:0] ldst_misc_off_imm;

	core_decode_ldst_misc group_ldst_misc
	(
		.decode(ldst_misc),
		.off_imm(ldst_misc_off_imm),
		.off_reg(ldst_misc_off_reg),
		.off_is_reg(ldst_misc_off_is_reg),
		.*
	);

	logic ldst_mult_restore_spsr;
	ldst_decode ldst_multiple;

	core_decode_ldst_multiple group_ldst_multiple
	(
		.decode(ldst_multiple),
		.restore_spsr(ldst_mult_restore_spsr),
		.*
	);

	ldst_decode ldst_addr;
	data_decode data_ldst;

	core_decode_ldst_addr ldst2data
	(
		.ldst(ldst_addr),
		.alu(data_ldst)
	);

	logic mul_update_flags;
	reg_num mul_rd, mul_rs, mul_rm;

	core_decode_mul group_mul
	(
		.decode(mul_ctrl),
		.rd(mul_rd),
		.rs(mul_rs),
		.rm(mul_rm),
		.update_flags(mul_update_flags),
		.*
	);

	logic coproc_writeback, coproc_update_flags;
	reg_num coproc_rd;

	core_decode_coproc group_coproc
	(
		.rd(coproc_rd),
		.decode(coproc_ctrl),
		.writeback(coproc_writeback),
		.update_flags(coproc_update_flags),
		.*
	);

	//TODO
	logic mrs_spsr;
	reg_num mrs_rd;

	core_decode_mrs group_mrs
	(
		.rd(mrs_rd),
		.spsr(mrs_spsr),
		.*
	);

	//TODO
	logic msr_spsr, msr_is_imm;
	msr_mask msr_fields;

	core_decode_msr group_msr
	(
		.spsr(msr_spsr),
		.fields(msr_fields),
		.snd_is_imm(msr_is_imm),
		.*
	);

endmodule
