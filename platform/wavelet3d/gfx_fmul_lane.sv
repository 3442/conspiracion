module gfx_fmul_lane
(
	input  logic              clk,

	input  gfx::float_special a,
	                          b,
	input  logic              slow_in,

	output gfx::float_round   q
);

	import gfx::*;

	/* Queremos calcular q = a * b.
	 *
	 * Donde a = (-1)^s * 1.m * 2^f,
	 *       b = (-1)^t * 1.n * 2^g
	 *
	 * Entonces q = (-1)^(s + t) (1.m * 1.n) 2^(f + g)
	 *
	 * El producto es entre números >= 1.0 y < 2.0. En el peor caso:
	 *   Mejor caso: 1.000... * 1.000... ~ 1.000...
	 *   Peor caso:  1.999... * 1.999... ~ 3.999... = 2^1 * 1.999
	 *
	 * Así que, si el producto es >= 2, hay que hacerle >> 1 a la mantisa
	 * y sumarle 1 al exponente para normalizar.
	 */

	logic guard, lo_msb, lo_reduce, overflow_0, overflow_1,
	      round, sign, slow_0, slow_1, zero;

	float_exp exp;
	float_round out;
	float_mant_full hi;
	logic[$bits(float_mant_full) - 3:0] lo;

	assign lo_msb = lo[$bits(lo) - 1];
	assign lo_reduce = |lo[$bits(lo) - 2:0];

	always_comb begin
		q = out;
		q.slow = slow_1 | overflow_1;
	end

	always_ff @(posedge clk) begin
		// Stage 0: producto

		sign <= a.val.sign ^ b.val.sign;
		zero <= a.exp_min | b.exp_min;
		slow_0 <= slow_in;

		{overflow_0, exp} <= {1'b0, a.val.exp} + {1'b0, b.val.exp} - {1'b0, FLOAT_EXP_BIAS};
		{hi, guard, round, lo} <= full_mant(a.val.mant) * full_mant(b.val.mant);

		// Stage 1: normalización

		slow_1 <= slow_0 | overflow_0;
		overflow_1 <= 0;

		out.slow <= 1'bx; // Ver 'q'
		out.zero <= zero;
		out.normal.sign <= sign;

		if (hi[$bits(hi) - 1]) begin
			out.guard <= guard;
			out.round <= round;
			out.sticky <= lo_msb | lo_reduce;
			out.normal.mant <= implicit_mant(hi);
			{overflow_1, out.normal.exp} <= {1'b0, exp} + 1;
		end else begin
			/* Bit antes de msb es necesariamente 1, ya que los msb de
			 * ambos multiplicandos son 1. Ver assert en implicit_mant().
			 */
			out.guard <= round;
			out.round <= lo[$bits(lo) - 1];
			out.sticky <= lo_reduce;
			out.normal.exp <= exp;
			out.normal.mant <= implicit_mant({hi[$bits(hi) - 2:0], guard});
		end
	end

endmodule
