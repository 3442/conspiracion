`include "gfx/gfx_defs.sv"

module gfx_fixed_div
(
	input  logic  clk,

	input  fixed  z,
	              d,
	input  logic  stall,

	output fixed  q
);

	localparam DIV_BITS = `FIXED_FRAC + $bits(fixed);

	fixed d_hold, z_hold;
	logic signed[DIV_BITS - 1:0] z_int, q_int;

	assign q = q_int[$bits(q) - 1:0];
	assign z_int = {z_hold, {`FIXED_FRAC{1'b0}}};

`ifndef VERILATOR
	lpm_divide div
	(
		.aclr(0),
		.clock(clk),
		.clken(!stall),
		.numer(z_int),
		.denom(d_hold),
		.remain(),
		.quotient(q_int)
	);

	defparam
		div.lpm_widthn          = DIV_BITS,
		div.lpm_widthd          = $bits(fixed),
		div.lpm_nrepresentation = "SIGNED",
		div.lpm_drepresentation = "SIGNED",
		div.lpm_pipeline        = `FIXED_DIV_STAGES - `FIXED_DIV_PIPES,
		div.maximize_speed      = 6;

	gfx_pipes #(.WIDTH($bits(z)), .DEPTH(`FIXED_DIV_PIPES)) z_pipes
	(
		.in(z),
		.out(z_hold),
		.*
	);

	gfx_pipes #(.WIDTH($bits(d)), .DEPTH(`FIXED_DIV_PIPES)) d_pipes
	(
		.in(d),
		.out(d_hold),
		.*
	);
`else
	logic signed[DIV_BITS - 1:0] d_int_hold, z_int_hold;

	assign q_int = z_int_hold / d_int_hold;
	assign z_hold = z;
	assign d_int_hold = {{`FIXED_FRAC{d_hold[$bits(d_hold) - 1]}}, d_hold};

	gfx_pipes #(.WIDTH($bits(z_int)), .DEPTH(`FIXED_DIV_STAGES)) z_int_pipes
	(
		.in(z_int),
		.out(z_int_hold),
		.*
	);

	gfx_pipes #(.WIDTH($bits(d)), .DEPTH(`FIXED_DIV_STAGES)) d_pipes
	(
		.in(d),
		.out(d_hold),
		.*
	);
`endif

endmodule
