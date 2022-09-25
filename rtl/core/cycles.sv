`include "core/uarch.sv"

module core_cycles
(
	input  logic    clk,
	                decode_execute,
	                decode_writeback,
	                decode_branch,
	input  ptr      decode_branch_offset,
	input  reg_num  decode_rd,
	input  ptr      fetch_insn_pc,

	output logic    stall,
	                branch,
	                writeback,
	output ptr      branch_target,
	                pc,
	                pc_visible,
	output psr_mode reg_mode
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
		stall <= next_cycle != EXECUTE;

		if(next_cycle == EXECUTE) begin
			branch <= 0;
			writeback <= 0;
			branch_target <= 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

			if(decode_execute) begin
				branch <= decode_branch;
				writeback <= decode_writeback;
				branch_target <= pc_visible + decode_branch_offset;
			end

			pc <= fetch_insn_pc;
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
