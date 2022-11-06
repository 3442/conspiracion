`include "core/uarch.sv"

module core_control_mul
(
	input  logic           clk,

	input  datapath_decode dec,
	input  mul_decode      dec_mul,
	input  logic           mul_ready,

	input  ctrl_cycle      next_cycle,
	input  logic           issue,

	output logic           mul,
	                       mul_add,
	                       mul_long,
	                       mul_signed
);

	always_ff @(posedge clk)
		if(next_cycle == ISSUE && issue) begin
			mul <= dec.mul;
			mul_add <= dec_mul.add;
			mul_long <= dec_mul.long_mul;
			mul_signed <= dec_mul.signed_mul;
		end

	initial begin
		mul = 0;
		mul_add = 0;
		mul_long = 0;
		mul_signed = 0;
	end

endmodule
