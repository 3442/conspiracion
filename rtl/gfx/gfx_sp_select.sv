`include "gfx/gfx_defs.sv"

module gfx_sp_select
(
	input  logic         clk,

	input  vec4          a,
	                     b,
	input  shuffler_deco deco,
	input  logic         stall,

	output vec4          out
);

	always_ff @(posedge clk)
		if (!stall)
			for (integer i = 0; i < `FLOATS_PER_VEC; ++i)
				if (deco.is_broadcast)
					out[i] <= deco.imm;
				else if (deco.select_mask[i])
					out[i] <= b[i];
				else
					out[i] <= a[i];

endmodule
