`include "core/isa.sv"
`include "core/psr.sv"
`include "core/uarch.sv"

module core_decode
(
	input  logic[31:0] insn,
	input  psr_flags   flags,
	output logic       execute,
	                   undefined
);

	logic cond_undefined;

	//TODO
	logic link;
	logic[29:0] offset;
	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.undefined(cond_undefined),
		.*
	);

	logic branch_link;
	logic[29:0] branch_offset;

	core_decode_branch branch
	(
		.*
	);

	//TODO
	alu_op op;
	reg_num rn, rd;
	logic writeback, update_flags, restore_spsr, zero_fst, negate_fst, negate_snd, carry_in;
	core_decode_data data
	(
		.*
	);

	always_comb begin
		undefined = cond_undefined;

		priority case(insn `FIELD_OP) inside
			`GROUP_B: ;

			`GROUP_ALU: begin
			end

			`INSN_MUL: ;
			`GROUP_BIGMUL: ;
			`GROUP_LDST_MISC: ;
			`GROUP_LDST_MULT: ;
			`GROUP_SWP: ;
			`GROUP_CP: ;
			`INSN_MRS: ;
			`GROUP_MSR: ;
			`INSN_SWI: ;

			default: undefined = 1;
		endcase
	end

endmodule
