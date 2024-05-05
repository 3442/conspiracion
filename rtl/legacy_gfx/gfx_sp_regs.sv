`include "gfx/gfx_defs.sv"

module gfx_sp_regs
(
	input  logic    clk,

	input  vreg_num rd_a_reg,
	output mat4     rd_a_data,

	input  vreg_num rd_b_reg,
	output mat4     rd_b_data,

	input  logic    wr,
	input  vreg_num wr_reg,
	input  mat4     wr_data
);

	genvar i;
	generate
		for (i = 0; i < `GFX_SP_LANES; ++i) begin: lanes
			gfx_sp_file a
			(
				.rd_reg(rd_a_reg),
				.rd_data(rd_a_data[i]),
				.wr_data(wr_data[i]),
				.*
			);

			gfx_sp_file b
			(
				.rd_reg(rd_b_reg),
				.rd_data(rd_b_data[i]),
				.wr_data(wr_data[i]),
				.*
			);
		end
	endgenerate

endmodule
