`include "core/uarch.sv"

module core_control_coproc
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,

	output logic       coproc
);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n)
			coproc <= 0;
		else if(next_cycle.issue && issue)
			coproc <= dec.ctrl.coproc;

endmodule
