`include "core/uarch.sv"

module core_control_writeback
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,
	input  psr_flags   alu_flags,
	input  word        q_alu,
	                   ldst_read,
	input  logic       mem_ready,
	                   mem_write,
	input  word        mul_q_hi,
	                   mul_q_lo,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  word        saved_base,
	                   vector,
	                   psr_wb,
	input  reg_num     ra,
	                   popped,
	                   mul_r_add_hi,
	input  logic       issue,
	                   pop_valid,
	                   ldst_next,

	output reg_num     rd,
	                   final_rd,
	output logic       writeback,
	                   final_writeback,
	                   update_flags,
	                   final_update_flags,
	output word        wr_value
);

	reg_num last_rd;

	always_comb begin
		rd = last_rd;
		if(next_cycle.transfer) begin
			if(mem_ready)
				rd = final_rd;
		end else if(next_cycle.issue || next_cycle.base_writeback)
			rd = final_rd;
		else if(next_cycle.exception)
			rd = `R15;
		else if(next_cycle.mul_hi_wb)
			rd = mul_r_add_hi;

		if(next_cycle.issue)
			writeback = final_writeback;
		else if(next_cycle.transfer)
			writeback = mem_ready && !mem_write;
		else if(next_cycle.base_writeback)
			writeback = !mem_write;
		else if(next_cycle.exception || next_cycle.mul_hi_wb)
			writeback = 1;
		else
			writeback = 0;

		if(cycle.transfer)
			wr_value = ldst_read;
		else if(cycle.base_writeback)
			wr_value = saved_base;
		else if(cycle.mul || cycle.mul_hi_wb)
			wr_value = mul_q_lo;
		else if(cycle.psr)
			wr_value = psr_wb;
		else
			// Ruta combinacional larga
			wr_value = q_alu;

		if(next_cycle.transfer) begin
			if(mem_ready)
				wr_value = ldst_read;
		end else if(next_cycle.base_writeback)
			wr_value = ldst_read;
		else if(next_cycle.exception)
			wr_value = vector;
		else if(next_cycle.mul_hi_wb)
			wr_value = mul_q_hi;

		update_flags = 0;
		if(next_cycle.issue)
			update_flags = final_update_flags;
		else if(next_cycle.exception)
			update_flags = 0;
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			last_rd <= 0;
			final_rd <= 0;
			final_writeback <= 0;
			final_update_flags <= 0;
		end else begin
			last_rd <= rd;

			if(next_cycle.issue)
				final_rd <= dec.data.rd;
			else if(next_cycle.transfer) begin
				if(ldst_next && pop_valid)
					final_rd <= popped;
			end else if(next_cycle.base_writeback)
				final_rd <= ra;
			else if(next_cycle.exception)
				final_rd <= `R14;

			if(next_cycle.issue)
				final_writeback <= issue && dec.ctrl.writeback;
			else if(next_cycle.exception)
				final_writeback <= 1;

			if(next_cycle.issue)
				final_update_flags <= issue && dec.psr.update_flags;
			else if(next_cycle.exception)
				final_update_flags <= 0;
		end

endmodule
