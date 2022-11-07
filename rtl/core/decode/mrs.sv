`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_mrs
(
	input  word    insn,

	output reg_num rd,
	output logic   spsr
);

	assign rd = insn `FIELD_MRS_RD;
	assign spsr = insn `FIELD_MRS_R;

endmodule
