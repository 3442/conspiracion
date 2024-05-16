module gfx_shader_group
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  group_op          op,
	input  wave_exec         wave,

	       gfx_regfile_io.ab read_data,

	       if_shake.rx       in_shake,

	       gfx_wb.tx         wb
);

	word foo;

endmodule
