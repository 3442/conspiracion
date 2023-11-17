`include "gfx/gfx_defs.sv"

module gfx_fixed_fma
(
	input  logic clk,

	input  fixed a,
	             b,
	             c,
	input  logic stall,

	output fixed q
);

`ifndef VERILATOR
	logic[2 * $bits(fixed) - `FIXED_FRAC - 1:0] q_ext;
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
		mult.lpm_widths         = $bits(fixed) + `FIXED_FRAC,
		/* Esto es crucial. No está documentado en ningún lado (aparte de un
		 * comentario en r/fpga). Si lpm_widthp < lpm_widtha + lpm_widthb,
		 * entonces result contiene los lpm_widthp bits más significativos
		 * del producto, no los menos significativos como tendría sentido.
		 */
		mult.lpm_widthp         = 2 * $bits(fixed) - `FIXED_FRAC,
		mult.lpm_representation = "SIGNED",
		mult.lpm_pipeline       = `FIXED_FMA_STAGES;
`else
	logic[$bits(fixed) + `FIXED_FRAC - 1:0] q_ext;

	fixed a_hold, b_hold, c_hold;

	assign q = q_ext[$bits(fixed) + `FIXED_FRAC - 1:`FIXED_FRAC] + c_hold;
	assign q_ext = a_hold * b_hold;

	gfx_pipes #(.WIDTH($bits(a)), .DEPTH(`FIXED_FMA_STAGES)) a_pipes
	(
		.in(a),
		.out(a_hold),
		.*
	);

	gfx_pipes #(.WIDTH($bits(b)), .DEPTH(`FIXED_FMA_STAGES)) b_pipes
	(
		.in(b),
		.out(b_hold),
		.*
	);

	gfx_pipes #(.WIDTH($bits(c)), .DEPTH(`FIXED_FMA_STAGES)) c_pipes
	(
		.in(c),
		.out(c_hold),
		.*
	);
`endif

endmodule
