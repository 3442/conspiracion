`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_snd
(
	input  word       insn,
	input  logic      is_imm,
	                  ror_if_imm,
	                  shift_by_reg_if_reg,

	output snd_decode decode,
	output logic      undefined
);

	reg_num r, r_shift;
	logic shift_by_reg, shl, shr, ror, put_carry, sign_extend;
	logic[11:0] imm;
	logic[5:0] shift_imm;

	assign decode.r = r;
	assign decode.r_shift = r_shift;
	assign decode.shift_by_reg = shift_by_reg;
	assign decode.is_imm = is_imm;
	assign decode.shl = shl;
	assign decode.shr = shr;
	assign decode.ror = ror;
	assign decode.put_carry = put_carry;
	assign decode.sign_extend = sign_extend;
	assign decode.imm = imm;
	assign decode.shift_imm = shift_imm;

	assign r = insn `FIELD_SND_RM;
	assign r_shift = insn `FIELD_SND_RS;
	assign imm = ror_if_imm ? {4'b0, insn `FIELD_SND_IMM8} : insn `FIELD_SND_IMM12;
	assign shift_by_reg = ~is_imm & shift_by_reg_if_reg;
	assign undefined = shift_by_reg & insn `FIELD_SND_ZEROIFREG;

	logic[1:0] shift_op;
	assign shift_op = insn `FIELD_SND_SHIFT;

	always_comb begin
		ror = is_imm;
		shr = ~is_imm;
		put_carry = 0;
		sign_extend = 1'bx;

		if(is_imm && !ror_if_imm)
			shift_imm = 6'b0;
		else if(is_imm && !ror_if_imm)
			shift_imm = {1'b0, insn `FIELD_SND_ROR8, 1'b0};
		else begin
			shift_imm = {1'b0, insn `FIELD_SND_SHIFTIMM};

			case(shift_op)
				`SHIFT_LSL: shr = 0;
				`SHIFT_LSR: sign_extend = 0;
				`SHIFT_ASR: sign_extend = 1;
				`SHIFT_ROR: ;
			endcase

			if(~shift_by_reg & (shift_imm == 0))
				case(shift_op)
					`SHIFT_LSL: ;

					`SHIFT_LSR, `SHIFT_ASR:
						shift_imm = 6'd32;

					`SHIFT_ROR: begin
						// RRX
						shift_imm = 6'd1;
						put_carry = 1;
						sign_extend = 0;
					end
				endcase
			else if(shift_op == `SHIFT_ROR)
				ror = 1;
		end
	end

endmodule
