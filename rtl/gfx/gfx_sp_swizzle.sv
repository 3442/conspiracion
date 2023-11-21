`include "gfx/gfx_defs.sv"

module gfx_sp_swizzle
(
	input  logic         clk,

	input  vec4          in,
	input  shuffler_deco deco,
	input  logic         stall,

	output vec4          out
);

	always_ff @(posedge clk)
		if (!stall)
			for (integer i = 0; i < `FLOATS_PER_VEC; ++i)
				out[i] <= in[deco.swizzle_op[i]];

endmodule
