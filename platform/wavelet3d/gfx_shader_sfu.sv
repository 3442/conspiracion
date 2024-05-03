module gfx_shader_sfu
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  sfu_op            op,

	       gfx_regfile_io.ab read_data,

	       gfx_shake.rx      in_shake,

	       gfx_wb.tx         wb
);

endmodule
