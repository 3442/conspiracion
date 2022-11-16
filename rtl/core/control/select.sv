`include "core/uarch.sv"

module core_control_select
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,

	input  ctrl_cycle  next_cycle,
	input  logic       mem_ready,
	                   pop_valid,
	                   ldst_next,
	input  reg_num     popped,
	                   final_rd,
	                   mul_r_add_lo,
	                   mul_r_add_hi,

	output reg_num     ra,
	                   rb
);

	reg_num r_shift, last_ra, last_rb;

	always_comb begin
		ra = last_ra;
		rb = last_rb;

		if(next_cycle.issue) begin
			ra = dec.data.rn;
			rb = dec.snd.r;
		end else if(next_cycle.transfer) begin
			if(ldst_next)
				// final_rd viene de dec.ldst.rd
				rb = pop_valid ? popped : final_rd;
		end else if(next_cycle.mul_acc_ld) begin
			ra = mul_r_add_hi;
			rb = mul_r_add_lo;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			last_ra <= {$bits(ra){1'b0}};
			last_rb <= {$bits(rb){1'b0}};
			r_shift <= {$bits(r_shift){1'b0}};
		end else begin
			last_ra <= ra;
			last_rb <= rb;

			if(next_cycle.issue)
				r_shift <= dec.snd.r_shift;
		end

endmodule
