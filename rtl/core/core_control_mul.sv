`include "core/uarch.sv"

module core_control_mul
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,
	input  logic       mul_ready,
	input  word        rd_value_a,
	                   rd_value_b,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  logic       issue,

	output word        mul_a,
	                   mul_b,
	                   mul_c_hi,
	                   mul_c_lo,
	output reg_num     mul_r_add_hi,
	                   mul_r_add_lo,
	output logic       mul,
	                   mul_add,
	                   mul_long,
	                   mul_start,
	                   mul_signed
);

	word hold_a, hold_b;

	assign {mul_c_hi, mul_c_lo} = {rd_value_a, rd_value_b};
	assign {mul_a, mul_b} = mul_add ? {hold_a, hold_b} : {rd_value_a, rd_value_b};

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			mul <= 0;
			mul_add <= 0;
			mul_long <= 0;
			mul_start <= 0;
			mul_signed <= 0;
			mul_r_add_hi <= {$bits(mul_r_add_hi){1'b0}};
			mul_r_add_lo <= {$bits(mul_r_add_lo){1'b0}};

			hold_a <= 0;
			hold_b <= 0;
		end else begin
			mul_start <= 0;

			if(next_cycle.issue) begin
				mul <= issue && dec.ctrl.mul;
				mul_add <= dec.mul.add;
				mul_long <= dec.mul.long_mul;
				mul_signed <= dec.mul.signed_mul;
				mul_r_add_hi <= dec.mul.r_add_hi;
				mul_r_add_lo <= dec.mul.r_add_lo;
			end else if(next_cycle.mul)
				mul_start <= !cycle.mul;
			else if(next_cycle.mul_acc_ld) begin
				hold_a <= rd_value_a;
				hold_b <= rd_value_b;
			end
		end

	//TODO: mul update_flags

endmodule
