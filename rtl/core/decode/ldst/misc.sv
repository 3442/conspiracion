`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_ldst_misc
(
	input  word        insn,

	output ldst_decode decode
);

	logic p, w;

	assign decode.rn = insn `FIELD_LDST_MISC_RN;
	assign decode.rd = insn `FIELD_LDST_MISC_RD;
	assign decode.size = insn `FIELD_LDST_MISC_H ? LDST_HALF : LDST_BYTE;
	assign decode.load = insn `FIELD_LDST_LD;
	assign decode.increment = insn `FIELD_LDST_MISC_U;
	assign decode.writeback = !p || w;
	assign decode.sign_extend = insn `FIELD_LDST_MISC_S;
	assign decode.pre_indexed = p && w;
	assign decode.unprivileged = 0;
	assign decode.user_regs = 0;
	assign decode.reg_list = 16'b0;

	assign p = insn `FIELD_LDST_MISC_P;
	assign w = insn `FIELD_LDST_MISC_W;

endmodule
