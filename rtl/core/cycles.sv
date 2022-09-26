`include "core/uarch.sv"

module core_cycles
(
	input  logic       clk,
	                   dec_execute,
	                   dec_branch,
	                   dec_writeback,
	                   dec_update_flags,
	input  ptr         dec_branch_offset,
	input  alu_decode  dec_alu,
	input  ptr         fetch_insn_pc,
	input  word        rd_value_b,

	output logic       stall,
	                   branch,
	                   writeback,
	                   update_flags,
	output reg_num     rd,
	                   ra,
	                   rb,
	output ptr         branch_target,
	                   pc,
	                   pc_visible,
	output psr_mode    reg_mode,
	output alu_control alu,
	output word        alu_base,
	output logic[7:0]  alu_shift
);

	enum
	{
		EXECUTE,
		RD_SHIFT
	} cycle, next_cycle;

	logic final_writeback, data_snd_is_imm, data_snd_shift_by_reg;
	logic[5:0] data_shift_imm;
	logic[7:0] data_imm;
	word saved_base;
	reg_num r_shift;

	assign stall = next_cycle != EXECUTE;
	assign pc_visible = pc + 2;
	assign reg_mode = `MODE_SVC; //TODO

	always_comb begin
		next_cycle = EXECUTE;
		if((cycle == EXECUTE) & data_snd_shift_by_reg)
			next_cycle = RD_SHIFT;

		unique case(cycle)
			RD_SHIFT:
				alu_base = saved_base;

			default:
				if(data_snd_is_imm)
					alu_base = {{24{1'b0}}, data_imm};
				else
					alu_base = rd_value_b;
		endcase

		unique case(cycle)
			RD_SHIFT: alu_shift = rd_value_b[7:0];
			default:  alu_shift = {2'b00, data_shift_imm};
		endcase
	end

	always_ff @(posedge clk) begin
		cycle <= next_cycle;

		unique case(next_cycle)
			EXECUTE: begin
				branch <= 0;
				writeback <= 0;
				update_flags <= 0;
				branch_target <= 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

				if(dec_execute) begin
					branch <= dec_branch;
					writeback <= dec_writeback & ~dec_alu.snd_shift_by_reg;
					update_flags <= dec_update_flags;
					branch_target <= pc_visible + dec_branch_offset;

					data_snd_is_imm <= dec_alu.snd_is_imm;
					data_snd_shift_by_reg <= dec_alu.snd_shift_by_reg;
					data_imm <= dec_alu.imm;
					data_shift_imm <= dec_alu.shift_imm;

					alu.op <= dec_alu.op;
					alu.shl <= dec_alu.shl;
					alu.shr <= dec_alu.shr;
					alu.ror <= dec_alu.ror;
					alu.put_carry <= dec_alu.put_carry;
					alu.sign_extend <= dec_alu.sign_extend;

					rd <= dec_alu.rd;
					ra <= dec_alu.rn;
					rb <= dec_alu.r_snd;
					r_shift <= dec_alu.r_shift;

					final_writeback <= dec_writeback;
				end

				pc <= fetch_insn_pc;
			end

			RD_SHIFT: begin
				rb <= r_shift;
				data_snd_shift_by_reg <= 0;
				saved_base <= rd_value_b;
				writeback <= final_writeback;
			end
		endcase
	end

	initial begin
		cycle = EXECUTE;

		branch = 1;
		writeback = 0;
		data_snd_shift_by_reg = 0;
		branch_target = 30'd0;
		pc = 0;
	end

endmodule
