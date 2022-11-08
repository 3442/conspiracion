`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_data
(
	input  word        insn,

	output data_decode decode,
	output logic       snd_is_imm,
	                   snd_shift_by_reg_if_reg,
	                   writeback,
	                   conditional,
	                   update_flags,
	                   restore_spsr
);

	alu_op op;
	reg_num rn, rd;
	logic uses_rn;

	assign decode.op = op;
	assign decode.rn = rn;
	assign decode.rd = rd;
	assign decode.uses_rn = uses_rn;

	assign rn = insn `FIELD_DATA_RN;
	assign rd = insn `FIELD_DATA_RD;
	assign op = insn `FIELD_DATA_OPCODE;

	assign snd_is_imm = insn `FIELD_DATA_IMM;
	assign snd_shift_by_reg_if_reg = insn `FIELD_DATA_REGSHIFT;

	always_comb begin
		unique case(op)
			`ALU_ADC, `ALU_SBC, `ALU_RSC:
				conditional = 1;

			default:
				conditional = 0;
		endcase

		unique case(op)
			`ALU_CMP, `ALU_CMN, `ALU_TST, `ALU_TEQ:
				writeback = 0;

			default:
				writeback = 1;
		endcase

		unique case(op)
			`ALU_MOV, `ALU_MVN:
				uses_rn = 0;

			default:
				uses_rn = 1;
		endcase

		update_flags = insn `FIELD_DATA_S;
		restore_spsr = (rd == `R15) & update_flags;

		if(restore_spsr)
			update_flags = 0;
	end

endmodule
