`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_data
(
	input  word       insn,

	output alu_decode decode,
	output logic      writeback,
	                  update_flags,
	                  restore_spsr,
	                  undefined
);

	alu_op op;
	reg_num rn, rd, r_snd, r_shift;
	logic snd_shift_by_reg, snd_is_imm, shl, shr, ror, put_carry, sign_extend;
	logic[7:0] imm;
	logic[5:0] shift_imm;

	assign decode.op = op;
	assign decode.rn = rn;
	assign decode.rd = rd;
	assign decode.r_snd = r_snd;
	assign decode.r_shift = r_shift;
	assign decode.snd_shift_by_reg = snd_shift_by_reg;
	assign decode.snd_is_imm = snd_is_imm;
	assign decode.shl = shl;
	assign decode.shr = shr;
	assign decode.ror = ror;
	assign decode.put_carry = put_carry;
	assign decode.sign_extend = sign_extend;
	assign decode.imm = imm;
	assign decode.shift_imm = shift_imm;

	assign rn = insn `FIELD_DATA_RN;
	assign rd = insn `FIELD_DATA_RD;
	assign op = insn `FIELD_DATA_OPCODE;
	assign r_snd = insn `FIELD_DATA_RM;
	assign r_shift = insn `FIELD_DATA_RS;
	assign imm = insn `FIELD_DATA_IMM8;
	assign snd_is_imm = insn `FIELD_DATA_IMM;
	assign snd_shift_by_reg = ~snd_is_imm & insn `FIELD_DATA_REGSHIFT;
	assign undefined = snd_shift_by_reg & insn `FIELD_DATA_ZEROIFREG;

	logic[1:0] shift_op;
	assign shift_op = insn `FIELD_DATA_SHIFT;

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

		ror = snd_is_imm;
		shr = ~snd_is_imm;
		put_carry = 0;
		sign_extend = 1'bx;

		if(snd_is_imm)
			shift_imm = {1'b0, insn `FIELD_DATA_ROR8, 1'b0};
		else begin
			shift_imm = {1'b0, insn `FIELD_DATA_SHIFTIMM};

			case(shift_op)
				`SHIFT_LSL: shr = 0;
				`SHIFT_LSR: sign_extend = 0;
				`SHIFT_ASR: sign_extend = 1;
				`SHIFT_ROR: ;
			endcase

			if(~snd_shift_by_reg & (shift_imm == 0))
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
