package gfx;

	typedef logic[31:0] word;
	typedef logic[63:0] dword;
	typedef logic[7:0]  float_exp;

	typedef logic[$bits(word) - $bits(float_exp) - 2:0] float_mant;
	typedef logic[$bits(float_mant):0] float_mant_full; // Incluye '1.' explícito

	localparam float_exp FLOAT_EXP_BIAS = (1 << ($bits(float_exp) - 1)) - 1;
	localparam float_exp FLOAT_EXP_MAX  = {($bits(float_exp)){1'b1}};

	function float_mant_full full_mant(float_mant in);
		full_mant = {1'b1, in};
	endfunction

	function float_mant implicit_mant(float_mant_full in);
		assert (in[$bits(in) - 1]);
		implicit_mant = in[$bits(in) - 2:0];
	endfunction

	typedef struct packed
	{
		logic      sign;
		float_exp  exp;
		float_mant mant;
	} float;

	/* Explicación de guard, round, sticky:
	 * https://drilian.com/2023/01/10/floating-point-numbers-and-rounding/
	 */
	typedef struct packed
	{
		float normal;
		logic slow,
		      zero,
		      guard,
		      round,
		      sticky;
	} float_round;

	typedef struct packed
	{
		logic exp_max,
		      exp_min,
		      mant_zero;
	} float_class;

	function float_class classify_float(float in);
		classify_float.exp_max = &in.exp;
		classify_float.exp_min = ~|in.exp;
		classify_float.mant_zero = ~|in.mant;
	endfunction

	function logic is_float_special(float_class in);
		is_float_special = in.exp_max | (in.exp_min & ~in.mant_zero);
	endfunction

	/* -> 4,4,4,4,4,4,4,4 -> 8,8,8,8 -> 16,16 -> 32
	 */
	localparam FADD_CLZ_STAGES = 4;

	typedef struct packed
	{
		logic fadd,
		      fmul;
	} arith_op;

endpackage
