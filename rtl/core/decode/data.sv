`include "core/isa.sv"
`include "core/psr.sv"
`include "core/uarch.sv"

module core_decode_data
(
	input  word    insn,

	output alu_op  op,
	output reg_num rn,
	               rd,
	output logic   writeback,
	               update_flags,
	               restore_spsr
);

	assign rn = insn `FIELD_DATA_RN;
	assign rd = insn `FIELD_DATA_RD;
	assign op = insn `FIELD_DATA_OPCODE;

	always_comb begin
		unique case(op)
			`ALU_CMP, `ALU_CMN, `ALU_TST, `ALU_TEQ:
				writeback = 0;

			default:
				writeback = 1;
		endcase

		update_flags = insn `FIELD_DATA_S;
		restore_spsr = (rd == `R15) & update_flags;

		if(restore_spsr)
			update_flags = 0;
	end

endmodule
