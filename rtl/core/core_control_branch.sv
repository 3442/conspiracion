`include "core/uarch.sv"

module core_control_branch
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,
	input  ptr         next_pc_visible,

	output logic       branch,
	output ptr         branch_target
);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			branch <= 1;
			branch_target <= {$bits(branch_target){1'b0}};
		end else begin
			branch <= 0;
			if(next_cycle.issue && issue) begin
				branch <= dec.ctrl.branch;
				branch_target <= next_pc_visible + dec.branch.offset;
			end
		end

endmodule
