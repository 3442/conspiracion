module gfx_round_lane
(
	input  logic            clk,

	input  gfx::float_round in,

	output gfx::float       out
);

	import gfx::*;

	logic exp_step, overflow, sign_0, sign_1, slow_0, slow_1,
	      slow_out, zero_0, zero_1;

	float_exp exp_0, exp_1;
	float_mant mant_0, mant_1;

	assign slow_out = slow_1 || overflow || &exp_1;

	always_ff @(posedge clk) begin
		// Stage 0: redondeo

		exp_0 <= in.normal.exp;
		sign_0 <= in.normal.sign;
		slow_0 <= in.slow;
		zero_0 <= in.zero;
		exp_step <= 0;

		// Este es el modo más común: round to nearest, ties to even
		if (in.guard & (in.round | in.sticky | in.normal.mant[0]))
			{exp_step, mant_0} <= {1'b0, in.normal.mant} + 1;
		else
			mant_0 <= in.normal.mant;

		sign_1 <= sign_0;
		slow_1 <= slow_0;
		zero_1 <= zero_0;
		mant_1 <= mant_0;
		overflow <= 0;

		if (exp_step)
			{overflow, exp_1} <= {1'b0, exp_0} + 1;
		else
			exp_1 <= exp_0;

		// Stage 1: ceros y slow path

		out.sign <= sign_1;

		if (slow_out) begin
			out.exp <= FLOAT_EXP_MAX;
			out.mant <= 1;
		end else if (zero_1) begin
			out.exp <= 0;
			out.mant <= 0;
		end else begin
			out.exp <= exp_1;
			out.mant <= mant_1;
		end
	end

endmodule
