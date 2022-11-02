`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word            insn,
	input  psr_flags       flags,

	output datapath_decode ctrl,
	output branch_decode   branch_ctrl,
	output snd_decode      snd_ctrl,
	output data_decode     data_ctrl,
	output ldst_decode     ldst_ctrl,
	output mul_decode      mul_ctrl,
	output coproc_decode   coproc_ctrl
);

	logic execute, undefined, conditional, writeback,
	      update_flags, branch, ldst, mul, coproc;

	assign ctrl.execute = execute;
	assign ctrl.undefined = undefined;
	assign ctrl.conditional = conditional;
	assign ctrl.writeback = writeback;
	assign ctrl.update_flags = update_flags;
	assign ctrl.branch = branch;
	assign ctrl.coproc = coproc;
	assign ctrl.ldst = ldst;
	assign ctrl.mul = mul;

	//TODO
	logic restore_spsr;

	logic cond_undefined, cond_execute;

	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.execute(cond_execute),
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
		.offset(branch_ctrl.offset),
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

	always_comb begin
		mul = 0;
		ldst = 0;
		branch = 0;
		coproc = 0;

		execute = cond_execute;
		undefined = cond_undefined;
		writeback = 0;
		update_flags = 0;

		data_ctrl = {($bits(data_ctrl)){1'bx}};
		data_ctrl.uses_rn = 1;

		snd_ctrl = {$bits(snd_ctrl){1'bx}};
		snd_ctrl.shr = 0;
		snd_ctrl.ror = 0;
		snd_ctrl.is_imm = 1;
		snd_ctrl.shift_imm = {$bits(snd_ctrl.shift_imm){1'b0}};
		snd_ctrl.shift_by_reg = 0;

		snd_is_imm = 1'bx;
		snd_ror_if_imm = 1'bx;
		snd_shift_by_reg_if_reg = 1'bx;

		ldst_addr = {($bits(ldst_addr)){1'bx}};
		ldst_ctrl = {($bits(ldst_ctrl)){1'bx}};

		// El orden de los casos es importante, NO CAMBIAR
		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					data_ctrl.op = `ALU_SUB;
					data_ctrl.rd = `R14;
					data_ctrl.rn = `R15;
					snd_ctrl.imm = 12'd4;
					writeback = 1;
				end
			end

			`GROUP_MUL: begin
				mul = 1;

				data_ctrl.rd = mul_rd;
				data_ctrl.rn = mul_rs;

				snd_ctrl.is_imm = 0;
				snd_ctrl.r = mul_rm;
				snd_ctrl.shift_by_reg = 0;

				writeback = 1;
				update_flags = mul_update_flags;
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

			`GROUP_LDST_SINGLE_IMM, `GROUP_LDST_SINGLE_REG: begin
				snd_is_imm = ldst_single_is_imm;
				snd_ror_if_imm = 0;
				snd_shift_by_reg_if_reg = 0;

				snd_ctrl = snd;
				ldst_ctrl = ldst_single;
				ldst_addr = ldst_single;

				undefined = undefined | snd_undefined;
			end

			`GROUP_LDST_MISC_IMM, `GROUP_LDST_MISC_REG:
				priority casez(insn `FIELD_OP)
					`INSN_LDRB, `INSN_LDRSB, `INSN_LDRSH, `INSN_STRH: begin
						ldst_ctrl = ldst_misc;
						ldst_addr = ldst_misc;

						snd_ctrl.r = ldst_misc_off_reg;
						snd_ctrl.imm = {4'b0, ldst_misc_off_imm};
						snd_ctrl.is_imm = !ldst_misc_off_is_reg;
					end

					default:
						undefined = 1;
				endcase

			`GROUP_LDST_MULT: begin
				ldst_ctrl = ldst_multiple;
				ldst_addr = ldst_multiple;
				snd_ctrl.imm = 12'd4;

				restore_spsr = ldst_mult_restore_spsr;
			end

			`GROUP_CP: begin
				coproc = 1;
				writeback = coproc_writeback;
				update_flags = coproc_update_flags;

				data_ctrl.op = `ALU_MOV;
				data_ctrl.rn = coproc_rd;
				data_ctrl.rd = coproc_rd;
				data_ctrl.uses_rn = coproc_ctrl.load;
			end

			/*`GROUP_SWP: ;
			`INSN_MRS: ;
			`GROUP_MSR: ;
			`INSN_SWI: ;*/

			default: undefined = 1;
		endcase

		unique casez(insn `FIELD_OP)
			`GROUP_LDST_SINGLE, `GROUP_LDST_MISC, `GROUP_LDST_MULT: begin
				ldst = 1;
				data_ctrl = data_ldst;
				writeback = ldst_ctrl.writeback || ldst_ctrl.load;
			end

			default: ;
		endcase

		if(undefined) begin
			execute = 0;

			mul = 1'bx;
			ldst = 1'bx;
			branch = 1'bx;
			coproc = 1'bx;
			writeback = 1'bx;
			conditional = 1'bx;
			update_flags = 1'bx;

			snd_ctrl = {($bits(snd_ctrl)){1'bx}};
			data_ctrl = {($bits(data_ctrl)){1'bx}};
			ldst_ctrl = {($bits(ldst_ctrl)){1'bx}};
		end
	end

endmodule
