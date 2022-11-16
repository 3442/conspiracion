`include "core/uarch.sv"

module core_control_psr
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,
	input  word        cpsr_rd,
	                   spsr_rd,
	                   alu_b,
	input  psr_mode    mode,

	input  ctrl_cycle  next_cycle,
	input  logic       issue,

	output logic       psr,
	                   psr_saved,
	                   psr_write,
	                   psr_wr_flags,
	                   psr_wr_control,
	                   final_psr_write,
	                   final_restore_spsr,
	output word        psr_wb,
	                   psr_wr,
	output psr_mode    reg_mode
);

	assign psr_wb = psr_saved ? spsr_rd : cpsr_rd;
	assign psr_wr = final_restore_spsr ? spsr_rd : alu_b;
	assign psr_write = next_cycle.issue && (final_psr_write || final_restore_spsr);

	//TODO: casos donde esto no es cierto
	assign reg_mode = mode;

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			psr <= 0;
			psr_saved <= 0;
			psr_wr_flags <= 0;
			psr_wr_control <= 0;

			final_psr_write <= 0;
			final_restore_spsr <= 0;
		end else if(next_cycle.issue) begin
			psr <= issue && dec.ctrl.psr;
			psr_saved <= dec.psr.saved;
			psr_wr_flags <= dec.psr.wr_flags;
			psr_wr_control <= dec.psr.wr_control;

			final_psr_write <= issue && dec.psr.write;
			final_restore_spsr <= issue && dec.psr.restore_spsr;
		end else if(next_cycle.psr)
			psr <= 0;

endmodule
