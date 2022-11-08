`include "core/uarch.sv"

module core_control_branch
(
	input  logic       clk,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,
	input  ptr         next_pc_visible,

	output logic       branch,
	output ptr         branch_target
);

	always_ff @(posedge clk) begin
		branch <= 0;
		if(next_cycle == ISSUE && issue) begin
			branch <= dec.ctrl.branch;
			branch_target <= next_pc_visible + dec.branch.offset;
		end
	end

	initial begin
		branch = 1;
		branch_target = {$bits(branch_target){1'b0}};
	end

endmodule
