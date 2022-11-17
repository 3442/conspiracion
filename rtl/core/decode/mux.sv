`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_mux
(
	input  word          insn,

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
	                     ldst_misc_off_is_imm,
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
	                     branch,
	                     ldst,
	                     mul,
	                     psr,
	                     coproc,
	                     psr_saved,
	                     psr_write,
	                     psr_wr_flags,
	                     psr_wr_control,
	                     update_flags,
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
		execute = 1;
		undefined = 0;
		writeback = 0;
		conditional = 0;
		restore_spsr = 0;

		psr = 0;
		psr_saved = 0;
		psr_write = 0;
		update_flags = 0;
		psr_wr_flags = 1;
		psr_wr_control = 1;

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

		dec_ldst = {($bits(dec_ldst)){1'bx}};
		ldst_addr = {($bits(ldst_addr)){1'bx}};

		// El orden de los casos es importante, NO CAMBIAR
		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				dec_data.uses_rn = branch_link;

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

			`GROUP_LDST_MISC: begin
				dec_ldst = ldst_misc;
				ldst_addr = ldst_misc;

				dec_snd.r = ldst_misc_off_reg;
				dec_snd.imm = {4'b0, ldst_misc_off_imm};
				dec_snd.is_imm = ldst_misc_off_is_imm;
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

				undefined = snd_undefined;
				conditional = data_conditional;
			end

			`GROUP_LDST_SINGLE: begin
				snd_is_imm = ldst_single_is_imm;
				snd_ror_if_imm = 0;
				snd_shift_by_reg_if_reg = 0;

				dec_snd = snd;
				dec_ldst = ldst_single;
				ldst_addr = ldst_single;

				undefined = snd_undefined;
			end

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
				dec_data.rd = mrs_rd;
				dec_data.uses_rn = 0;

				psr = 1;
				psr_saved = mrs_spsr;
				writeback = 1;
				conditional = 1;
			end

			`GROUP_MSR: begin
				dec_data.uses_rn = 0;

				snd_is_imm = msr_is_imm;
				snd_ror_if_imm = 1;
				snd_shift_by_reg_if_reg = 0;

				psr = 1;
				dec_snd = snd;
				psr_write = 1;
				psr_saved = msr_spsr;
				conditional = 1;
				psr_wr_flags = msr_fields.f;
				psr_wr_control = msr_fields.c;
			end

			/*`GROUP_SWP: ;
			`INSN_SWI: ;*/

		   /* No es parte de ARMv4 pero U-Boot lo necesita. esto se
		    * decodifica igual que `mov pc, lr` ya que no tenemos Thumb.
			*/
		   `INSN_BXLR: begin
				dec_data.op = `ALU_MOV;
				dec_data.rd = `R15;
				dec_data.uses_rn = 0;

				dec_snd.r = `R14;
				dec_snd.is_imm = 0;

				writeback = 1;
			end

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
			psr = 1'bx;
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
