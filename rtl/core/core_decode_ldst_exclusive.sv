`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_ldst_exclusive
(
	input  word        insn,

	output ldst_decode decode,
	output reg_num     snd_r
);

	assign snd_r = insn `FIELD_LDST_EX_R_OK;

	assign decode.rn = insn `FIELD_LDST_EX_RN;
	assign decode.rd = insn `FIELD_LDST_EX_RD;
	assign decode.size = LDST_WORD;
	assign decode.load = insn `FIELD_LDST_EX_LD;
	assign decode.increment = 0;
	assign decode.writeback = 0;
	assign decode.exclusive = 1;
	assign decode.sign_extend = 0;
	assign decode.pre_indexed = 0;
	assign decode.unprivileged = 0;
	assign decode.user_regs = 0;
	assign decode.regs = 16'b0;

endmodule
