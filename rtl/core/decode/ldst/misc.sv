`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_ldst_misc
(
	input  word        insn,

	output ldst_decode decode,
	output logic       off_is_imm,
	output logic[7:0]  off_imm,
	output reg_num     off_reg
);

	logic p, w;

	assign decode.rn = insn `FIELD_LDST_MISC_RN;
	assign decode.rd = insn `FIELD_LDST_MISC_RD;
	assign decode.size = insn `FIELD_LDST_MISC_H ? LDST_HALF : LDST_BYTE;
	assign decode.load = insn `FIELD_LDST_LD;
	assign decode.increment = insn `FIELD_LDST_MISC_U;
	assign decode.writeback = !p || w;
	assign decode.exclusive = 0;
	assign decode.sign_extend = insn `FIELD_LDST_MISC_S;
	assign decode.pre_indexed = p;
	assign decode.unprivileged = 0;
	assign decode.user_regs = 0;
	assign decode.regs = 16'b0;

	assign off_imm = {insn `FIELD_LDST_MISC_IMM_HI, insn `FIELD_LDST_MISC_IMM_LO};
	assign off_reg = insn `FIELD_LDST_MISC_RM;
	assign off_is_imm = insn `FIELD_LDST_MISC_IMM;

	assign p = insn `FIELD_LDST_MISC_P;
	assign w = insn `FIELD_LDST_MISC_W;

endmodule
