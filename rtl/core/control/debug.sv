`include "core/uarch.sv"

module core_control_debug
(
	input  logic       clk,
	                   rst_n,
	                   step,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,
	                   next_bubble,
	input  insn_decode dec,

	output logic       breakpoint
);

	logic stable, step_trigger;

	assign stable = next_cycle.issue && !dec.ctrl.nop && !next_bubble;
	assign breakpoint = stable && (dec.ctrl.bkpt || step_trigger);

	always @(posedge clk or negedge rst_n)
		step_trigger <= !rst_n ? 0 : step && (step_trigger || stable) && !breakpoint;

endmodule
