`include "gfx/gfx_defs.sv"

module gfx_transpose
(
	input  mat4 in,
	output mat4 out
);

	integer i, j;

	// Esto no tiene costo en hardware, es un renombramiento de señales
	always_comb
		for (i = 0; i < `VECS_PER_MAT; ++i)
			for (j = 0; j < `FLOATS_PER_VEC; ++j)
				out[i][j] = in[j][i];

endmodule
