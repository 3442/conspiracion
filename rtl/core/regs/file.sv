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

	always @(posedge clk)
		if(wr_enable)
			file[rd_index] <= wr_value;

	always @(posedge clk)
		rd_value <= wr_enable & (rd_index == wr_index) ? wr_value : file[rd_index];

endmodule
