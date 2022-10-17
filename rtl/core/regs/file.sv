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
	word file[30] /*verilator public*/;

	//FIXME: Esto claramente no sirve
`ifdef VERILATOR
	always_ff @(negedge clk) begin
`else
	always_ff @(posedge clk) begin
`endif
		if(wr_enable)
			file[wr_index] <= wr_value;

		rd_value <= file[rd_index];
	end

endmodule
