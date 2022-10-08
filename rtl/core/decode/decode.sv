`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word        insn,
	input  psr_flags   flags,

	output logic       execute,
	                   undefined,
	                   writeback,
	                   update_flags,
	                   branch,
	output ptr         branch_offset,
	output snd_decode  snd_ctrl,
	output data_decode data_ctrl
);

	//TODO
	logic restore_spsr;
	ldst_decode ldst_ctrl;

	logic cond_undefined;

	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.undefined(cond_undefined),
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
		.offset(branch_offset),
		.*
	);

	data_decode data;
	logic data_writeback, data_update_flags, data_restore_spsr,
	      data_is_imm, data_shift_by_reg_if_reg;

	core_decode_data group_data
	(
		.decode(data),
		.writeback(data_writeback),
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

	core_decode_ldst_misc group_ldst_misc
	(
		.decode(ldst_misc),
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

	always_comb begin
		undefined = cond_undefined;

		branch = 0;
		writeback = 0;
		update_flags = 0;
		data_ctrl = {($bits(data_ctrl)){1'bx}};

		snd_ctrl = {($bits(snd_ctrl)){1'bx}};
		snd_ctrl.shl = 0;
		snd_ctrl.shr = 0;
		snd_ctrl.ror = 0;
		snd_is_imm = 1'bx;
		snd_ror_if_imm = 1'bx;
		snd_shift_by_reg_if_reg = 1'bx;

		ldst_ctrl = {($bits(ldst_ctrl)){1'bx}};
		ldst_ctrl.enable = 0;

		// El orden de los casos es importante, NO CAMBIAR
		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					data_ctrl.rd = `R14;
					writeback = 1;
					//TODO: Valor de LR
				end
			end

			`GROUP_ALU: begin
				snd_is_imm = data_is_imm;
				snd_ror_if_imm = 1;
				snd_shift_by_reg_if_reg = data_shift_by_reg_if_reg;

				snd_ctrl = snd;
				data_ctrl = data;

				writeback = data_writeback;
				update_flags = data_update_flags;
				restore_spsr = data_restore_spsr;
				undefined = undefined | snd_undefined;
			end

			`INSN_MUL: ;
			`GROUP_BIGMUL: ;

			`GROUP_LDST_SINGLE_IMM, `GROUP_LDST_SINGLE_REG: begin
				snd_is_imm = ldst_single_is_imm;
				snd_ror_if_imm = 0;
				snd_shift_by_reg_if_reg = 0;

				snd_ctrl = snd;
				ldst_ctrl = ldst_single;
				ldst_ctrl.enable = 1;

				undefined = undefined | snd_undefined;
			end

			`GROUP_LDST_MISC_IMM, `GROUP_LDST_MISC_REG:
				priority casez(insn `FIELD_OP)
					`INSN_LDRB, `INSN_LDRSB, `INSN_LDRSH, `INSN_STRH: begin
						ldst_ctrl = ldst_misc;
						ldst_ctrl.enable = 1;
					end

					default: undefined = 1;
				endcase

			`GROUP_LDST_MULT: begin
				ldst_ctrl = ldst_multiple;
				ldst_ctrl.enable = 1;
				restore_spsr = ldst_mult_restore_spsr;
			end

			`GROUP_SWP: ;
			`GROUP_CP: ;
			`INSN_MRS: ;
			`GROUP_MSR: ;
			`INSN_SWI: ;

			default: undefined = 1;
		endcase

		if(undefined) begin
			branch = 1'bx;
			writeback = 1'bx;
			snd_ctrl = {($bits(snd_ctrl)){1'bx}};
			data_ctrl = {($bits(data_ctrl)){1'bx}};
			ldst_ctrl = {($bits(ldst_ctrl)){1'bx}};
		end
	end

endmodule
