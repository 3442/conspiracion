`include "gfx/gfx_defs.sv"

module gfx_shuffle
(
	input  logic    clk,

	input  vec4     a,
	                b,
	input  vec_mask select,
	input  logic    stall,

	output vec4     out
);

	always_ff @(posedge clk)
		if (!stall)
			for (integer i = 0; i < `FLOATS_PER_VEC; ++i)
				out[i] <= select[i] ? b[i] : a[i];

endmodule
