`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_mul
(
	input  word       insn,

	output mul_decode decode,
	output reg_num    rd,
	                  rs,
	                  rm,
	output logic      update_flags
);

	logic long_mul;
	reg_num short_rd, rn;

	assign rd = long_mul ? rn : short_rd;
	assign rs = insn `FIELD_MUL_RS;
	assign rm = insn `FIELD_MUL_RM;
	assign update_flags = insn `FIELD_MUL_S;

	assign decode.add = insn `FIELD_MUL_ACC;
	assign decode.long_mul = long_mul;
	assign decode.signed_mul = insn `FIELD_MUL_SIGNED;
	assign decode.r_add_lo = long_mul ? rn : short_rd;
	assign decode.r_add_hi = short_rd;

	assign long_mul = insn `FIELD_MUL_LONG;
	assign short_rd = insn `FIELD_MUL_RD;
	assign rn = insn `FIELD_MUL_RN;

endmodule
