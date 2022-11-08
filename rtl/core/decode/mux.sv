`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_mux
(
	input  word          insn,

	input  logic         cond_undefined,
	                     cond_execute,
	                     explicit_cond,

	input  logic         branch_link,

	input  snd_decode    snd,
	input  logic         snd_undefined,

	input  data_decode   data,
	input  logic         data_writeback,
	                     data_conditional,
	                     data_update_flags,
	                     data_restore_spsr,
	                     data_is_imm,
	                     data_shift_by_reg_if_reg,

	input  ldst_decode   ldst_single,
	                     ldst_misc,
	                     ldst_multiple,
	input  logic         ldst_single_is_imm,
	                     ldst_misc_off_is_reg,
	input  reg_num       ldst_misc_off_reg,
	input  logic[7:0]    ldst_misc_off_imm,
	input  logic         ldst_mult_restore_spsr,
	input  data_decode   data_ldst,

	input  logic         mul_update_flags,
	input  reg_num       mul_rd,
	                     mul_rs,
	                     mul_rm,

	input  coproc_decode dec_coproc,
	input  logic         coproc_writeback,
	                     coproc_update_flags,
	input  reg_num       coproc_rd,

	input  logic         msr_spsr,
	                     msr_is_imm,
	                     mrs_spsr,
	input  reg_num       mrs_rd,
	input  msr_mask      msr_fields,

	output snd_decode    dec_snd,
	output data_decode   dec_data,
	output ldst_decode   dec_ldst,
	                     ldst_addr,
	output logic         execute,
	                     undefined,
	                     conditional,
	                     writeback,
	                     update_flags,
	                     branch,
	                     ldst,
	                     mul,
	                     coproc,
	                     spsr,
	                     psr_write,
	                     restore_spsr,
	                     snd_is_imm,
	                     snd_ror_if_imm,
	                     snd_shift_by_reg_if_reg
);

	always_comb begin
		mul = 0;
		ldst = 0;
		branch = 0;
		coproc = 0;
		execute = cond_execute;
		undefined = cond_undefined;
		writeback = 0;
		conditional = explicit_cond;
		restore_spsr = 0;

		spsr = 0;
		psr_write = 0;
		update_flags = 0;

		dec_data = {($bits(dec_data)){1'bx}};
		dec_data.uses_rn = 1;

		dec_snd = {$bits(dec_snd){1'bx}};
		dec_snd.shr = 0;
		dec_snd.ror = 0;
		dec_snd.is_imm = 1;
		dec_snd.shift_imm = {$bits(dec_snd.shift_imm){1'b0}};
		dec_snd.shift_by_reg = 0;

		snd_is_imm = 1'bx;
		snd_ror_if_imm = 1'bx;
		snd_shift_by_reg_if_reg = 1'bx;

		ldst_addr = {($bits(ldst_addr)){1'bx}};
		dec_ldst = {($bits(dec_ldst)){1'bx}};

		// El orden de los casos es importante, NO CAMBIAR
		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					dec_data.op = `ALU_SUB;
					dec_data.rd = `R14;
					dec_data.rn = `R15;
					dec_snd.imm = 12'd4;
					writeback = 1;
				end
			end

			`GROUP_MUL: begin
				mul = 1;

				dec_data.rd = mul_rd;
				dec_data.rn = mul_rs;

				dec_snd.is_imm = 0;
				dec_snd.r = mul_rm;

				writeback = 1;
				update_flags = mul_update_flags;
			end

			`GROUP_ALU: begin
				snd_is_imm = data_is_imm;
				snd_ror_if_imm = 1;
				snd_shift_by_reg_if_reg = data_shift_by_reg_if_reg;

				dec_snd = snd;
				dec_data = data;

				writeback = data_writeback;
				update_flags = data_update_flags;
				restore_spsr = data_restore_spsr;

				undefined = undefined | snd_undefined;
				conditional = conditional | data_conditional;
			end

			`GROUP_LDST_SINGLE_IMM, `GROUP_LDST_SINGLE_REG: begin
				snd_is_imm = ldst_single_is_imm;
				snd_ror_if_imm = 0;
				snd_shift_by_reg_if_reg = 0;

				dec_snd = snd;
				dec_ldst = ldst_single;
				ldst_addr = ldst_single;

				undefined = undefined | snd_undefined;
			end

			`GROUP_LDST_MISC_IMM, `GROUP_LDST_MISC_REG:
				priority casez(insn `FIELD_OP)
					`INSN_LDRB, `INSN_LDRSB, `INSN_LDRSH, `INSN_STRH: begin
						dec_ldst = ldst_misc;
						ldst_addr = ldst_misc;

						dec_snd.r = ldst_misc_off_reg;
						dec_snd.imm = {4'b0, ldst_misc_off_imm};
						dec_snd.is_imm = !ldst_misc_off_is_reg;
					end

					default:
						undefined = 1;
				endcase

			`GROUP_LDST_MULT: begin
				dec_ldst = ldst_multiple;
				ldst_addr = ldst_multiple;
				dec_snd.imm = 12'd4;

				restore_spsr = ldst_mult_restore_spsr;
			end

			`GROUP_CP: begin
				coproc = 1;
				writeback = coproc_writeback;
				update_flags = coproc_update_flags;

				dec_data.op = `ALU_MOV;
				dec_data.rn = coproc_rd;
				dec_data.rd = coproc_rd;
				dec_data.uses_rn = dec_coproc.load;
			end

			`INSN_MRS: begin
				dec_snd.is_imm = 0;
				dec_snd.r = mrs_rd;

				writeback = 1;
				conditional = 1;
			end

			`GROUP_MSR: begin
				snd_is_imm = msr_is_imm;
				snd_ror_if_imm = 1;
				snd_shift_by_reg_if_reg = 0;

				dec_snd = snd;
				conditional = 1;
			end

			/*`GROUP_SWP: ;
			`INSN_SWI: ;*/

			default:
				undefined = 1;
		endcase

		unique casez(insn `FIELD_OP)
			// Codificación coincide con ldst
			`GROUP_MUL: ;

			`GROUP_LDST_SINGLE, `GROUP_LDST_MISC, `GROUP_LDST_MULT: begin
				ldst = 1;
				dec_data = data_ldst;
				writeback = dec_ldst.writeback || dec_ldst.load;
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

			dec_snd = {($bits(dec_snd)){1'bx}};
			dec_data = {($bits(dec_data)){1'bx}};
			dec_ldst = {($bits(dec_ldst)){1'bx}};
		end
	end

endmodule
