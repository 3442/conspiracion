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

	logic pc_rd_hazard, pc_wr_hazard, rn_pc_hazard, snd_pc_hazard,
		  flags_hazard, flags_dependency, updating_flags;

	assign stall = next_cycle != ISSUE || next_bubble;
	assign next_bubble = pc_rd_hazard || pc_wr_hazard || flags_hazard;

	//FIXME: pc_rd_hazard no debería definirse sin final_writeback?
	assign pc_rd_hazard = final_writeback && (rn_pc_hazard || snd_pc_hazard);
	assign pc_wr_hazard = final_writeback && final_rd == `R15;
	assign rn_pc_hazard = dec.data.uses_rn && dec.data.rn == `R15;
	assign snd_pc_hazard = !dec.snd.is_imm && dec.snd.r == `R15;

	assign flags_hazard = flags_dependency && updating_flags;

	assign updating_flags = final_update_flags || update_flags;
	assign flags_dependency = dec.psr.update_flags || dec.ctrl.conditional;

	always_ff @(posedge clk or negedge rst_n)
		bubble <= !rst_n ? 0 : next_cycle == ISSUE && next_bubble;

endmodule
