// Count trailing zeros (ctz), clz al revés
module gfx_ctz
#(int WIDTH = 0)
(
	input  logic                  clk,

	input  logic[WIDTH - 1:0]     value,
	output logic[$clog2(WIDTH):0] ctz
);

	logic[WIDTH - 1:0] value_rev;

	gfx_clz #(WIDTH) clz
	(
		.clk,
		.value(value_rev),
		.clz(ctz)
	);

	always_comb
		for (int i = 0; i < $bits(value); ++i)
			value_rev[i] = value[$bits(value) - i - 1];

endmodule
