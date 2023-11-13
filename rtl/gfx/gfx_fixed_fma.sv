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

	logic[$bits(fixed) + `FIXED_FRAC - 1:0] q_ext;

`ifndef VERILATOR
	assign q = q_ext[$bits(fixed) + `FIXED_FRAC - 1:`FIXED_FRAC];

	lpm_mult mult
	(
		.aclr(0),
		.clock(clk),
		.clken(!stall),

		.sum({c, {`FIXED_FRAC{1'b0}}}),
		.dataa({{`FIXED_FRAC{a[$bits(a) - 1]}}, a}),
		.datab({{`FIXED_FRAC{b[$bits(b) - 1]}}, b}),
		.result(q_ext)
	);

	defparam
		mult.lpm_widtha         = $bits(fixed) + `FIXED_FRAC,
		mult.lpm_widthb         = $bits(fixed) + `FIXED_FRAC,
		mult.lpm_widths         = $bits(fixed) + `FIXED_FRAC,
		mult.lpm_widthp         = $bits(fixed) + `FIXED_FRAC,
		mult.lpm_representation = "SIGNED",
		mult.lpm_pipeline       = `FIXED_FMA_STAGES;
`else
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
