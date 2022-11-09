`include "core/uarch.sv"

module core_control_stall
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       final_update_flags,
	                   update_flags,
	                   final_writeback,
	                   writeback,
	input  reg_num     final_rd,

	output logic       stall,
	                   bubble,
	                   next_bubble
);

	logic pc_writeback_hazard, flags_hazard, data_hazard, rn_hazard,
	      snd_hazard, flags_dependency, updating_flags;

	assign stall = next_cycle != ISSUE || next_bubble;
	assign next_bubble = pc_writeback_hazard || flags_hazard || data_hazard;

	assign pc_writeback_hazard = final_writeback && final_rd == `R15;
	assign flags_hazard = flags_dependency && updating_flags;
	assign data_hazard = final_writeback && (rn_hazard || snd_hazard);
	assign rn_hazard = dec.data.uses_rn && (final_rd == dec.data.rn || dec.data.rn == `R15);
	assign snd_hazard = !dec.snd.is_imm && (dec.snd.r == final_rd || dec.snd.r == `R15);

	assign flags_dependency = dec.psr.update_flags || dec.ctrl.conditional;
	assign updating_flags = final_update_flags || update_flags;

	always_ff @(posedge clk or negedge rst_n)
		bubble <= !rst_n ? 0 : next_cycle == ISSUE && next_bubble;

endmodule
