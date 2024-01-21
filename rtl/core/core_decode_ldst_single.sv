`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_ldst_single
(
	input  word        insn,

	output ldst_decode decode,
	output logic       snd_is_imm
);

	logic p, w;

	assign decode.rn = insn `FIELD_LDST_SINGLE_RN;
	assign decode.rd = insn `FIELD_LDST_SINGLE_RD;
	assign decode.size = insn `FIELD_LDST_SINGLE_B ? LDST_BYTE : LDST_WORD;
	assign decode.load = insn `FIELD_LDST_LD;
	assign decode.increment = insn `FIELD_LDST_SINGLE_U;
	assign decode.writeback = !p || w;
	assign decode.exclusive = 0;
	assign decode.sign_extend = 0;
	assign decode.pre_indexed = p;
	assign decode.unprivileged = !p && w;
	assign decode.user_regs = 0;
	assign decode.regs = 16'b0;

	assign p = insn `FIELD_LDST_SINGLE_P;
	assign w = insn `FIELD_LDST_SINGLE_W;
	assign snd_is_imm = !insn `FIELD_LDST_SINGLE_REG;

endmodule
