`include "core/uarch.sv"

module core_control_coproc
(
	input  logic       clk,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,

	output logic       coproc
);

	always_ff @(posedge clk)
		if(next_cycle == ISSUE && issue)
			coproc <= dec.ctrl.coproc;

	initial
		coproc = 0;

endmodule
