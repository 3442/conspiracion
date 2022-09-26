`include "core/uarch.sv"

module core_cycles
(
	input  logic      clk,
	                  dec_execute,
	                  dec_branch,
	                  dec_writeback,
	                  dec_update_flags,
	input  ptr        dec_branch_offset,
	input  alu_decode dec_alu,
	input  ptr        fetch_insn_pc,

	output logic       stall,
	                   branch,
	                   writeback,
	                   update_flags,
	output reg_num     rd,
	output ptr         branch_target,
	                   pc,
	                   pc_visible,
	output psr_mode    reg_mode,
	output alu_control alu
);

	enum
	{
		EXECUTE
	} cycle, next_cycle;

	assign stall = next_cycle != EXECUTE;
	assign pc_visible = pc + 2;
	assign next_cycle = EXECUTE; //TODO
	assign reg_mode = `MODE_SVC; //TODO

	always_ff @(posedge clk) begin
		cycle <= next_cycle;

		if(next_cycle == EXECUTE) begin
			branch <= 0;
			writeback <= 0;
			update_flags <= 0;
			branch_target <= 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

			if(dec_execute) begin
				branch <= dec_branch;
				writeback <= dec_writeback;
				branch_target <= pc_visible + dec_branch_offset;
			end

			alu.op <= dec_alu.op;
			alu.shl <= dec_alu.shl;
			alu.shr <= dec_alu.shr;
			alu.ror <= dec_alu.ror;
			alu.put_carry <= dec_alu.put_carry;
			alu.sign_extend <= dec_alu.sign_extend;

			pc <= fetch_insn_pc;
			rd <= dec_alu.rd;
			update_flags <= dec_update_flags;
		end
	end

	initial begin
		cycle = EXECUTE;

		branch = 1;
		writeback = 0;
		branch_target = 30'd0;
		pc = 0;
	end

endmodule
