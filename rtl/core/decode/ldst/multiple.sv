`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_ldst_multiple
(
	input  word        insn,

	output ldst_decode decode,
	output logic       restore_spsr
);

	logic s, l;
	logic[15:0] reg_list;

	assign decode.rn = insn `FIELD_LDST_MULT_RN;
	assign decode.size = LDST_WORD;
	assign decode.load = l;
	assign decode.increment = insn `FIELD_LDST_MULT_U;
	assign decode.writeback = insn `FIELD_LDST_MULT_W;
	assign decode.sign_extend = 0;
	assign decode.pre_indexed = insn `FIELD_LDST_MULT_P;
	assign decode.unprivileged = 0;
	assign decode.user_regs = s && (!l || !reg_list[`R15]);
	assign decode.reg_list = reg_list;

	assign s = insn `FIELD_LDST_MULT_S;
	assign l = insn `FIELD_LDST_LD;

	assign reg_list = insn `FIELD_LDST_MULT_LIST;
	assign restore_spsr = s && l && reg_list[`R15];

endmodule
