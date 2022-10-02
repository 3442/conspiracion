`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode
(
	input  word       insn,
	input  psr_flags  flags,

	output logic       execute,
	                   undefined,
	                   writeback,
	                   update_flags,
	                   branch,
	output ptr         branch_offset,
	output data_decode data_ctrl
);

	logic cond_undefined;

	//TODO
	core_decode_conds conds
	(
		.cond(insn `FIELD_COND),
		.undefined(cond_undefined),
		.*
	);

	logic branch_link;

	core_decode_branch group_branch
	(
		.link(branch_link),
		.offset(branch_offset),
		.*
	);

	//TODO
	logic restore_spsr;

	logic data_writeback, data_update_flags, data_undefined;
	data_decode data;

	core_decode_data group_data
	(
		.decode(data),
		.writeback(data_writeback),
		.update_flags(data_update_flags),
		.undefined(data_undefined),
		.*
	);

	always_comb begin
		undefined = cond_undefined;

		branch = 0;
		writeback = 0;
		update_flags = 0;
		data_ctrl = {($bits(data_ctrl)){1'bx}};

		priority casez(insn `FIELD_OP)
			`GROUP_B: begin
				branch = 1;
				if(branch_link) begin
					data_ctrl.rd = `R14;
					writeback = 1;
					//TODO: Valor de LR
				end
			end

			`GROUP_ALU: begin
				data_ctrl = data;
				writeback = data_writeback;
				update_flags = data_update_flags;
				undefined = undefined | data_undefined;
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
