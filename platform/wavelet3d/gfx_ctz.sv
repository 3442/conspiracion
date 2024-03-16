// Count trailing zeros (ctz), clz al revés
module gfx_ctz
#(int WIDTH = 0)
(
	input  logic                  clk,

	input  logic[WIDTH - 1:0]     value,
	output logic[$clog2(WIDTH):0] ctz
);

	gfx_clz #(WIDTH) clz
	(
		.clk,
		.value({<<{value}}),
		.clz(ctz)
	);

endmodule
