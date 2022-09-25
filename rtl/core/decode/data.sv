`include "core/isa.sv"
`include "core/psr.sv"
`include "core/uarch.sv"

module core_decode_data
(
	input  word      insn,
	input  psr_flags flags,

	output alu_op    op,
	output reg_num   rn,
	                 rd,
	output logic     writeback,
	                 update_flags,
	                 restore_spsr,
	                 zero_fst,
	                 negate_fst,
	                 negate_snd,
	                 carry_in
);

	assign rn = insn `FIELD_DATA_RN;
	assign rd = insn `FIELD_DATA_RD;

	always_comb begin
		update_flags = insn `FIELD_DATA_S;
		writeback = 1;

		op = ALU_ADD;
		zero_fst = 0;
		negate_fst = 0;
		negate_snd = 0;
		carry_in = 0;

		unique case(insn `FIELD_DATA_OPCODE)
			`DATA_ADD: ;

			`DATA_AND: op = ALU_AND;
			`DATA_EOR: op = ALU_XOR;
			`DATA_ORR: op = ALU_ORR;
			`DATA_SUB: negate_snd = 1;
			`DATA_RSB: negate_fst = 1;
			`DATA_ADC: carry_in = flags.c;
			`DATA_MOV: zero_fst = 1;
			`DATA_CMN: writeback = 0;

			`DATA_MVN: begin
				zero_fst = 1;
				negate_snd = 1;
			end

			`DATA_SBC: begin
				negate_snd = 1;
				carry_in = flags.c;
			end

			`DATA_RSC: begin
				negate_fst = 1;
				carry_in = flags.c;
			end

			`DATA_BIC: begin
				op = ALU_AND;
				negate_snd = 1;
				carry_in = 1;
			end

			`DATA_TST: begin
				op = ALU_AND;
				writeback = 0;
			end

			`DATA_TEQ: begin
				op = ALU_XOR;
				writeback = 0;
			end

			`DATA_CMP: begin
				writeback = 0;
				negate_snd = 1;
			end

		endcase

		restore_spsr = (rd == `R15) & update_flags;
		if(restore_spsr)
			update_flags = 0;
	end

endmodule
