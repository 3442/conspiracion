`include "core/isa.sv"
`include "core/psr.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word      insn,
	input  psr_flags flags,

	output logic     execute,
	                 undefined,
	                 writeback,
	                 branch,
	output ptr       branch_offset,
	output reg_num   rd
);

	logic cond_undefined;

	//TODO
	logic link;
	ptr offset;
	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.undefined(cond_undefined),
		.*
	);

	logic branch_link; //TODO

	core_decode_branch group_branch
	(
		.*
	);

	//TODO
	alu_op op;
	reg_num rn;
	logic update_flags, restore_spsr, zero_fst, negate_fst, negate_snd, carry_in;

	logic data_writeback;
	reg_num data_rd;

	core_decode_data group_data
	(
		.rd(data_rd),
		.writeback(data_writeback),
		.*
	);

	always_comb begin
		undefined = cond_undefined;

		branch = 0;
		writeback = 0;
		rd = 4'bxxxx;

		priority case(insn `FIELD_OP) inside
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					rd = `R14;
					writeback = 1;
					//TODO: Valor de LR
				end
			end

			`GROUP_ALU: begin
				rd = data_rd;
				writeback = data_writeback;
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

			default: begin
				undefined = 1;
				branch = 1'bx;
				writeback = 1'bx;
			end
		endcase
	end

endmodule
