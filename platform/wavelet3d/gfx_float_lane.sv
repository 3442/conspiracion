module gfx_float_lane
(
	input  logic      clk,

	input  gfx::float a,
	                  b,

	output gfx::float q
);

	import gfx::*;

	logic slow_fmul;
	float_round q_fmul;
	float_special a_special, b_special;

	function float_special front_flags(float in);
		front_flags.val = in;
		front_flags.exp_max = &in.exp;
		front_flags.exp_min = ~|in.exp;
		front_flags.mant_zero = ~|in.mant;
	endfunction

	function logic is_special(float_special in);
		is_special = in.exp_max | (in.exp_min & ~in.mant_zero);
	endfunction

	gfx_fadd_lane fmul
	(
		.clk(clk),
		.a(a_special),
		.b(b_special),
		.q(q_fmul),
		.slow_in(slow_fmul)
	);

	gfx_round_lane round
	(
		.clk(clk),
		.in(q_fmul),
		.out(q)
	);

	always_comb begin
		slow_fmul = is_special(a_special) | is_special(b_special);
	end

	always_ff @(posedge clk) begin
		a_special <= front_flags(a);
		b_special <= front_flags(b);
	end

endmodule
