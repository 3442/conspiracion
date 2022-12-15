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
	                   exception_mode,

	input  ctrl_cycle  cycle,
	                   next_cycle,
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

	word exception_spsr;

	assign psr_wb = psr_saved ? spsr_rd : cpsr_rd;

	//TODO: casos donde esto no es cierto
	assign reg_mode = mode;

	always_comb begin
		psr_write = 0;

		if(next_cycle.issue)
			psr_write = final_psr_write || final_restore_spsr;

		if(cycle.escalate || cycle.exception)
			psr_write = 1;

		if(cycle.escalate)
			//TODO: F (FIQ) no cambia siempre
			psr_wr = {24'b0, 3'b110, exception_mode};
		else if(cycle.exception)
			psr_wr = exception_spsr;
		else
			psr_wr = final_restore_spsr ? spsr_rd : alu_b;
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			psr <= 0;
			psr_saved <= 0;
			psr_wr_flags <= 0;
			psr_wr_control <= 0;

			exception_spsr <= 0;
			final_psr_write <= 0;
			final_restore_spsr <= 0;
		end else if(next_cycle.issue) begin
			psr <= issue && dec.ctrl.psr;
			psr_saved <= dec.psr.saved;
			psr_wr_flags <= dec.psr.wr_flags;
			psr_wr_control <= dec.psr.wr_control;

			final_psr_write <= issue && dec.psr.write;
			final_restore_spsr <= issue && dec.psr.restore_spsr;
		end else if(next_cycle.escalate) begin
			psr_saved <= 0;
			psr_wr_flags <= 0;
			psr_wr_control <= 1;
			exception_spsr <= cpsr_rd;
		end else if(next_cycle.exception) begin
			psr <= 0;
			psr_saved <= 1;
			psr_wr_flags <= 1;
		end else if(next_cycle.psr)
			psr <= 0;

endmodule
