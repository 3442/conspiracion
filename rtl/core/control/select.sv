`include "core/uarch.sv"

module core_control_select
(
	input  logic       clk,

	input  data_decode dec_data,
	input  snd_decode  dec_snd,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  logic       mem_ready,
	                   pop_valid,
	input  reg_num     popped,
	                   final_rd,
	                   mul_r_add_lo,
	                   mul_r_add_hi,

	output reg_num     ra,
	                   rb,
	output psr_mode    reg_mode
);

	reg_num r_shift, last_ra, last_rb;

	assign reg_mode = `MODE_SVC; //TODO

	always_comb begin
		ra = last_ra;
		rb = last_rb;

		unique case(next_cycle)
			ISSUE: begin
				ra = dec_data.rn;
				rb = dec_snd.r;
			end

			TRANSFER:
				if(cycle != TRANSFER || mem_ready)
					// final_rd viene de dec_ldst.rd
					rb = pop_valid ? popped : final_rd;

			MUL_ACC_LD: begin
				ra = mul_r_add_hi;
				rb = mul_r_add_lo;
			end
		endcase
	end

	always_ff @(posedge clk) begin
		last_ra <= ra;
		last_rb <= rb;

		if(next_cycle == ISSUE)
			r_shift <= dec_snd.r_shift;
	end

	initial begin
		last_ra = {$bits(ra){1'b0}};
		last_rb = {$bits(rb){1'b0}};
		r_shift = {$bits(r_shift){1'b0}};
	end

endmodule
