module gfx_fadd_lane
(
	input  logic              clk,

	input  gfx::float_special a,
	                          b,
	input  logic              slow_in,

	output gfx::float_round   q
);

	import gfx::*;

	// Queremos calcular q = a + b. Curiosamente, eso es más complicado que a * b.

	typedef logic[$bits(float_mant_full) + 1:0] extended;
	localparam bit[$clog2($bits(extended)):0] MAX_SHIFT = 1 << $clog2($bits(extended));

	localparam int SHIFT_WIDTH     = {{($bits(int) - $bits(MAX_SHIFT)){1'b0}}, MAX_SHIFT};
	localparam int CLZ_EXTEND_BITS = $bits(float_exp) - $bits(clz_shift) + 1;

	logic overflow, slow_0, slow_1, slow_2, slow_3, sticky, sticky_last;
	extended shifted_min, sticky_mask, max_mant;
	float_exp exp_delta;
	float_round out;
	float_special max_0, max_1, max_2, max_3, min_0, min_1, min_2, min_3;
	logic[$clog2(MAX_SHIFT):0] clz_shift, exp_shift;
	logic[$bits(float_mant_full) + 2:0] add_sub, normalized;

	struct packed
	{
		float_special               max,
		                            min;
		logic                       slow,
		                            sticky;
		logic[$bits(add_sub) - 1:0] add_sub;
	} clz_hold[FADD_CLZ_STAGES], clz_hold_out;

	gfx_clz #(SHIFT_WIDTH) clz
	(
		.clk(clk),
		.clz(clz_shift),
		.value({add_sub, {(SHIFT_WIDTH - $bits(add_sub)){1'b0}}})
	);

	function extended extend_min(float_special in);
		extend_min = {~in.exp_min, in.val.mant, 2'b00};
	endfunction

	assign max_mant = {~max_2.exp_min, max_2.val.mant, 2'b00};
	assign exp_delta = max_0.val.exp - min_0.val.exp;
	assign normalized = add_sub << clz_shift;
	assign clz_hold_out = clz_hold[FADD_CLZ_STAGES - 1];

	always_comb begin
		q = out;
		q.slow = out.slow || overflow;
		q.sticky = out.sticky || sticky_last;
	end

	always_ff @(posedge clk) begin
		/* Stage 0: ordenar tal que abs(max) >= abs(min). Wiki dice:
		 *
		 * A property of the single- and double-precision formats is that
		 * their encoding allows one to easily sort them without using
		 * floating-point hardware, as if the bits represented sign-magnitude
		 * integers, although it is unclear whether this was a design
		 * consideration (it seems noteworthy that the earlier IBM hexadecimal
		 * floating-point representation also had this property for normalized
		 * numbers).
		 */
		if ({b.val.exp, b.val.mant} > {a.val.exp, a.val.mant}) begin
			min_0 <= a;
			max_0 <= b;
		end else begin
			min_0 <= b;
			max_0 <= a;
		end

		slow_0 <= slow_in;

		// Stage 1: exp_shift amount

		max_1 <= max_0;
		min_1 <= min_0;
		slow_1 <= slow_0;

		exp_shift <= exp_delta[$bits(exp_shift) - 1:0];
		if (exp_delta > {{($bits(exp_delta) - $bits(MAX_SHIFT)){1'b0}}, MAX_SHIFT})
			exp_shift <= MAX_SHIFT;

		// Stage 2: shifts

		max_2 <= max_1;
		min_2 <= min_1;
		slow_2 <= slow_1;

		shifted_min <= extend_min(min_1) >> exp_shift;
		sticky_mask <= {($bits(shifted_min)){1'b1}} << exp_shift;

		// Stage 3: suma/resta y sticky

		max_3 <= max_2;
		min_3 <= min_2;
		slow_3 <= slow_2;

		sticky <= |(extend_min(min_2) & ~sticky_mask);
		if (max_2.val.sign ^ min_2.val.sign)
			add_sub <= {1'b0, max_mant - shifted_min};
		else
			add_sub <= {1'b0, max_mant} + {1'b0, shifted_min};

		// Stages 4-7: clz

		clz_hold[0].max <= max_3;
		clz_hold[0].min <= min_3;
		clz_hold[0].slow <= slow_3;
		clz_hold[0].sticky <= sticky;
		clz_hold[0].add_sub <= add_sub;

		for (int i = 1; i < FADD_CLZ_STAGES; ++i)
			clz_hold[i] <= clz_hold[i - 1];

		// Stage 8: normalización

		out.slow <= clz_hold_out.slow;
		out.sticky <= clz_hold_out.sticky;
		out.normal.sign <= clz_hold_out.max.val.sign;

		{out.normal.mant, out.guard, out.round, sticky_last} <=
			normalized[$bits(normalized) - 2:$bits(normalized) - $bits(out.normal.mant) - 4];

		if (clz_shift[$bits(clz_shift) - 1]) begin
			overflow <= 0;
			out.normal.exp <= 0;
		end else
			{overflow, out.normal.exp} <=
				{1'b0, clz_hold_out.max.val.exp} - {{CLZ_EXTEND_BITS{1'b0}}, clz_shift} + 1;
	end

endmodule
