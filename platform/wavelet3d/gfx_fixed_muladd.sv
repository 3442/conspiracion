module gfx_fixed_muladd
(
	input  logic      clk,

	input  gfx::fixed a,
	                  b,
	                  c,
	input  logic      stall,

	output gfx::fixed q
);

	import gfx::*;

`ifndef VERILATOR
	logic[2 * $bits(fixed) - $bits(fixed_frac) - 1:0] q_ext;

	assign q = q_ext[$bits(fixed) - 1:0];

	lpm_mult mult
	(
		.aclr(0),
		.clock(clk),
		.clken(!stall),

		.sum({c, {`FIXED_FRAC{1'b0}}}),
		.dataa(a),
		.datab(b),
		.result(q_ext)
	);

	defparam
		mult.lpm_widtha         = $bits(fixed),
		mult.lpm_widthb         = $bits(fixed),
		mult.lpm_widths         = $bits(fixed) + $bits(fixed_frac),
		/* Esto es crucial. No está documentado en ningún lado (aparte de un
		 * comentario en r/fpga). Si lpm_widthp < lpm_widtha + lpm_widthb,
		 * entonces result contiene los lpm_widthp bits más significativos
		 * del producto, no los menos significativos como tendría sentido.
		 */
		mult.lpm_widthp         = 2 * $bits(fixed) - $bits(fixed_frac),
		mult.lpm_representation = "SIGNED",
		mult.lpm_pipeline       = FIXED_MULADD_DEPTH;
`else
	logic[$bits(fixed) + $bits(fixed_frac) - 1:0] q_ext;

	fixed a_hold, b_hold, c_hold;

	assign q = q_ext[$bits(fixed) + $bits(fixed_frac) - 1:$bits(fixed_frac)] + c_hold;
	assign q_ext = a_hold * b_hold;

	gfx_pipes #(.WIDTH($bits(a)), .DEPTH(FIXED_MULADD_DEPTH)) a_pipes
	(
		.clk,
		.in(a),
		.out(a_hold),
		.stall
	);

	gfx_pipes #(.WIDTH($bits(b)), .DEPTH(FIXED_MULADD_DEPTH)) b_pipes
	(
		.clk,
		.in(b),
		.out(b_hold),
		.stall
	);

	gfx_pipes #(.WIDTH($bits(c)), .DEPTH(FIXED_MULADD_DEPTH)) c_pipes
	(
		.clk,
		.in(c),
		.out(c_hold),
		.stall
	);
`endif

endmodule
