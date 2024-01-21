`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_coproc
(
	input  word          insn,

	output coproc_decode decode,
	output reg_num       rd,
	output logic         writeback,
	                     update_flags
);

	assign rd = insn `FIELD_CP_RD;
	assign writeback = decode.load && rd != `R15;
	assign update_flags = decode.load && rd == `R15;

	assign decode.crn = insn `FIELD_CP_CRN;
	assign decode.crm = insn `FIELD_CP_CRM;
	assign decode.op1 = insn `FIELD_CP_OPCODE;
	assign decode.op2 = insn `FIELD_CP_OPCODE2;
	assign decode.load = insn `FIELD_CP_LOAD;

endmodule
