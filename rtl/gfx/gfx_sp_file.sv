`include "gfx/gfx_defs.sv"

module gfx_sp_file
(
	input  logic    clk,

	input  vreg_num rd_reg,
	output vec4     rd_data,

	input  logic    wr,
	input  vreg_num wr_reg,
	input  vec4     wr_data
);

	vec4 file[1 << $bits(vreg_num)], hold_rd_data, hold_wr_data;
	logic hold_wr;
	vreg_num hold_rd_reg, hold_wr_reg;

	always_ff @(posedge clk) begin
		hold_wr <= wr;
		hold_wr_reg <= wr_reg;
		hold_wr_data <= wr_data;

		rd_data <= hold_rd_data;
		hold_rd_reg <= rd_reg;
		hold_rd_data <= file[hold_rd_reg];

		if (hold_wr)
			file[hold_wr_reg] <= hold_wr_data;
	end

endmodule
