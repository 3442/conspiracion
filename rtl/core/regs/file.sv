`include "core/uarch.sv"

module core_reg_file
(
	input  logic     clk,
	input  reg_index rd_index,
	                 wr_index,
	input  logic     wr_enable,
	input  word      wr_value,

	output word      rd_value
);

	// Ver comentario en uarch.sv
	word file[30];
	word q, wr_value_hold;
	logic overwrite_hold;

	assign rd_value = overwrite_hold ? wr_value_hold : q;

	always @(negedge clk) begin
		if(wr_enable) begin
			file[wr_index] <= wr_value;
			wr_value_hold <= wr_value;
		end

		q <= file[rd_index];
		overwrite_hold <= wr_enable & (rd_index == wr_index);
	end

endmodule
