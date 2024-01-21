`include "core/uarch.sv"

module core_control_ldst_pop
(
	input  reg_list regs,

	output logic    valid,
	output reg_list next_upper,
	                next_lower,
	output reg_num  pop_upper,
	                pop_lower
);

	assign valid = regs != 16'b0;

	always_comb begin
		unique casez(regs)
			16'b???????????????1: begin pop_lower = 4'h0; next_lower = {regs[15:1],   1'b0}; end
			16'b??????????????10: begin pop_lower = 4'h1; next_lower = {regs[15:2],   2'b0}; end
			16'b?????????????100: begin pop_lower = 4'h2; next_lower = {regs[15:3],   3'b0}; end
			16'b????????????1000: begin pop_lower = 4'h3; next_lower = {regs[15:4],   4'b0}; end
			16'b???????????10000: begin pop_lower = 4'h4; next_lower = {regs[15:5],   5'b0}; end
			16'b??????????100000: begin pop_lower = 4'h5; next_lower = {regs[15:6],   6'b0}; end
			16'b?????????1000000: begin pop_lower = 4'h6; next_lower = {regs[15:7],   7'b0}; end
			16'b????????10000000: begin pop_lower = 4'h7; next_lower = {regs[15:8],   8'b0}; end
			16'b???????100000000: begin pop_lower = 4'h8; next_lower = {regs[15:9],   9'b0}; end
			16'b??????1000000000: begin pop_lower = 4'h9; next_lower = {regs[15:10], 10'b0}; end
			16'b?????10000000000: begin pop_lower = 4'ha; next_lower = {regs[15:11], 11'b0}; end
			16'b????100000000000: begin pop_lower = 4'hb; next_lower = {regs[15:12], 12'b0}; end
			16'b???1000000000000: begin pop_lower = 4'hc; next_lower = {regs[15:13], 13'b0}; end
			16'b??10000000000000: begin pop_lower = 4'hd; next_lower = {regs[15:14], 14'b0}; end
			16'b?100000000000000: begin pop_lower = 4'he; next_lower = {regs[15],    15'b0}; end
			default:              begin pop_lower = 4'hf; next_lower = 16'b0; end
		endcase

		unique casez(regs)
			16'b1???????????????: begin pop_upper = 4'hf; next_upper = { 1'b0, regs[14:0]}; end
			16'b01??????????????: begin pop_upper = 4'he; next_upper = { 2'b0, regs[13:0]}; end
			16'b001?????????????: begin pop_upper = 4'hd; next_upper = { 3'b0, regs[12:0]}; end
			16'b0001????????????: begin pop_upper = 4'hc; next_upper = { 4'b0, regs[11:0]}; end
			16'b00001???????????: begin pop_upper = 4'hb; next_upper = { 5'b0, regs[10:0]}; end
			16'b000001??????????: begin pop_upper = 4'ha; next_upper = { 6'b0, regs[9:0]}; end
			16'b0000001?????????: begin pop_upper = 4'h9; next_upper = { 7'b0, regs[8:0]}; end
			16'b00000001????????: begin pop_upper = 4'h8; next_upper = { 8'b0, regs[7:0]}; end
			16'b000000001???????: begin pop_upper = 4'h7; next_upper = { 9'b0, regs[6:0]}; end
			16'b0000000001??????: begin pop_upper = 4'h6; next_upper = {10'b0, regs[5:0]}; end
			16'b00000000001?????: begin pop_upper = 4'h5; next_upper = {11'b0, regs[4:0]}; end
			16'b000000000001????: begin pop_upper = 4'h4; next_upper = {12'b0, regs[3:0]}; end
			16'b0000000000001???: begin pop_upper = 4'h3; next_upper = {13'b0, regs[2:0]}; end
			16'b00000000000001??: begin pop_upper = 4'h2; next_upper = {14'b0, regs[1:0]}; end
			16'b000000000000001?: begin pop_upper = 4'h1; next_upper = {15'b0, regs[0]}; end
			default:              begin pop_upper = 4'h0; next_upper = 16'b0; end
		endcase
	end

endmodule
