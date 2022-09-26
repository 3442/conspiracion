`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word       insn,
	input  psr_flags  flags,

	output logic      execute,
	                  undefined,
	                  writeback,
	                  update_flags,
	                  branch,
	output ptr        branch_offset,
	output alu_decode alu
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
	logic restore_spsr;

	logic data_writeback, data_update_flags;
	alu_decode data_alu;

	core_decode_data group_data
	(
		.decode(data_alu),
		.writeback(data_writeback),
		.update_flags(data_update_flags),
		.*
	);

	always_comb begin
		undefined = cond_undefined;

		branch = 0;
		writeback = 0;
		update_flags = 0;
		alu = {($bits(alu)){1'bx}};

		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					alu.rd = `R14;
					writeback = 1;
					//TODO: Valor de LR
				end
			end

			`GROUP_ALU: begin
				alu = data_alu;
				writeback = data_writeback;
				update_flags = data_update_flags;
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
