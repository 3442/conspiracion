`include "core/uarch.sv"

module core_control_select
(
	input  logic       clk,

	input  data_decode dec_data,
	input  snd_decode  dec_snd,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  logic       issue,
	                   mem_ready,
	                   pop_valid,
	input  reg_num     popped,
	                   final_rd,

	output reg_num     ra,
	                   rb
);

	reg_num r_shift;

	always_ff @(posedge clk)
		unique0 case(next_cycle)
			ISSUE:
				if(issue) begin
					ra <= dec_data.rn;
					rb <= dec_snd.r;
					r_shift <= dec_snd.r_shift;
				end

			RD_INDIRECT_SHIFT:
				rb <= r_shift;

			TRANSFER:
				if(cycle != TRANSFER || mem_ready)
					// final_rd viene de dec_ldst.rd
					rb <= pop_valid ? popped : final_rd;
		endcase

	initial begin
		ra = {$bits(ra){1'b0}};
		rb = {$bits(rb){1'b0}};
		r_shift = {$bits(r_shift){1'b0}};
	end

endmodule
