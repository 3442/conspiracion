module gfx_shader_sfu
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  sfu_op            op,
	input  wave_exec         wave,

	       gfx_regfile_io.ab read_data,

	       if_shake.rx       in_shake,

	       gfx_wb.tx         wb
);

	word foo;

endmodule
