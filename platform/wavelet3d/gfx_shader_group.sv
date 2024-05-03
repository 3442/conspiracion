module gfx_shader_group
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  group_op          op,

	       gfx_regfile_io.ab read_data,

	       gfx_shake.rx      in_shake,

	       gfx_wb.tx         wb
);

endmodule
