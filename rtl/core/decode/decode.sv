`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word        insn,

	output insn_decode dec
);

	mul_decode dec_mul;
	psr_decode dec_psr;
	snd_decode dec_snd;
	ctrl_decode dec_ctrl;
	data_decode dec_data;
	ldst_decode dec_ldst;
	branch_decode dec_branch;
	coproc_decode dec_coproc;

	assign dec.mul = dec_mul;
	assign dec.psr = dec_psr;
	assign dec.snd = dec_snd;
	assign dec.ctrl = dec_ctrl;
	assign dec.data = dec_data;
	assign dec.ldst = dec_ldst;
	assign dec.branch = dec_branch;
	assign dec.coproc = dec_coproc;

	assign dec_ctrl.mul = mul;
	assign dec_ctrl.psr = psr;
	assign dec_ctrl.ldst = ldst;
	assign dec_ctrl.branch = branch;
	assign dec_ctrl.coproc = coproc;
	assign dec_ctrl.execute = execute;
	assign dec_ctrl.writeback = writeback;
	assign dec_ctrl.undefined = undefined;
	assign dec_ctrl.conditional = conditional;

	assign dec_psr.saved = psr_saved;
	assign dec_psr.write = psr_write;
	assign dec_psr.wr_flags = psr_wr_flags;
	assign dec_psr.wr_control = psr_wr_control;
	assign dec_psr.update_flags = update_flags;
	assign dec_psr.restore_spsr = restore_spsr;

	logic execute, undefined, conditional, writeback, update_flags,
	      restore_spsr, branch, ldst, mul, psr, coproc, psr_saved,
	      psr_write, psr_wr_flags, psr_wr_control;

	core_decode_mux mux
	(
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
		.offset(dec_branch.offset),
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
	logic ldst_misc_off_is_imm;
	reg_num ldst_misc_off_reg;
	logic[7:0] ldst_misc_off_imm;

	core_decode_ldst_misc group_ldst_misc
	(
		.decode(ldst_misc),
		.off_imm(ldst_misc_off_imm),
		.off_reg(ldst_misc_off_reg),
		.off_is_imm(ldst_misc_off_is_imm),
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
		.decode(dec_mul),
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
		.decode(dec_coproc),
		.writeback(coproc_writeback),
		.update_flags(coproc_update_flags),
		.*
	);

	logic mrs_spsr;
	reg_num mrs_rd;

	core_decode_mrs group_mrs
	(
		.rd(mrs_rd),
		.spsr(mrs_spsr),
		.*
	);

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
