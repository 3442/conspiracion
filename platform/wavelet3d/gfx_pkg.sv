package gfx;

	localparam int SHADER_LANES = 4;

	typedef logic[31:0] word;

	localparam int SUBWORD_BITS   = $clog2($bits(word)) - $clog2($bits(byte));
	localparam int BYTES_PER_WORD = 1 << SUBWORD_BITS;

	typedef word                                uword;
	typedef logic signed[$bits(word) - 1:0]     sword;
	typedef logic[$bits(word) / 2 - 1:0]        uhword;
	typedef logic signed[$bits(word) / 2 - 1:0] shword;
	typedef logic[2 * $bits(word) - 1:0]        udword;
	typedef logic signed[2 * $bits(word) - 1:0] sdword;

	typedef logic[7:0]                                  float_exp;
	typedef logic[$bits(word) - $bits(float_exp) - 2:0] float_mant;
	typedef logic[$bits(float_mant):0]                  float_mant_full; // Incluye '1.' explícito
	typedef logic[$bits(float_mant_full) + 1:0]         float_mant_ext;  // Considera overflow

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

	function float_mant_ext float_prepare_round(float in, float_class in_class);
		float_prepare_round = {~in_class.exp_min, in.mant, 2'b00};
	endfunction

	// -> 4,4,4,4,4,4,4,4 -> 8,8,8,8 -> 16,16 -> 32
	localparam int FPINT_CLZ_STAGES = 4;
	localparam int FPINT_STAGES     = 7 + FPINT_CLZ_STAGES + 4;

	localparam bit[$clog2($bits(float_mant_ext)):0] FPINT_MAX_SHIFT
		= 1 << $clog2($bits(float_mant_ext));

	typedef logic[$clog2(FPINT_MAX_SHIFT):0] fpint_shift;

	typedef struct packed
	{
		logic setup_mul_float,
		      setup_unit_b,
		      mnorm_put_hi,
		      mnorm_put_lo,
		      mnorm_put_mul,
		      mnorm_zero_b,
		      mnorm_zero_flags,
		      minmax_abs,
		      minmax_swap,
		      minmax_zero_min,
		      minmax_copy_flags,
		      shiftr_int_signed,
		      addsub_copy_flags,
		      addsub_int_operand,
		      clz_force_nop,
		      shiftl_copy_flags,
		      round_copy_flags,
		      round_enable,
		      encode_enable;
	} fpint_op;

	typedef struct packed
	{
		float a,
		      b,
		      a_mul,
		      b_mul;
	} fpint_setup_mulclass;

	typedef struct packed
	{
		float       b;
		float_exp   exp;
		float_class a_class,
		            b_class;
		udword      product;
		logic       sign,
		            overflow;
	} fpint_mulclass_mnorm;

	typedef struct packed
	{
		float       a,
		            b;
		float_class a_class,
		            b_class;
		logic       slow,
		            zero,
		            guard,
		            round,
		            sticky,
		            slow_in,
		            overflow;
	} fpint_mnorm_minmax;

	typedef struct packed
	{
		float       max,
		            min;
		float_class max_class,
		            min_class;
		logic       slow,
		            zero,
		            guard,
		            round,
		            sticky;
	} fpint_minmax_expdiff;

	typedef struct packed
	{
		float       max,
		            min;
		float_class max_class,
		            min_class;
		fpint_shift exp_shift;
		logic       slow,
		            zero,
		            guard,
		            round,
		            sticky;
	} fpint_expdiff_shiftr;

	typedef struct packed
	{
		float          max,
		               min;
		float_class    max_class,
		               min_class;
		float_mant_ext max_mant,
		               min_mant,
		               sticky_mask;
		logic          slow,
		               zero,
		               guard,
		               round,
		               sticky,
		               int_sign;
	} fpint_shiftr_addsub;

	typedef struct packed
	{
		float max;
		word  add_sub;
		logic slow,
		      zero,
		      guard,
		      round,
		      sticky;
	} fpint_clz_hold;

	typedef fpint_clz_hold fpint_addsub_clz;

	typedef struct packed
	{
		fpint_clz_hold hold;
		fpint_shift    shift;
	} fpint_clz_shiftl;

	typedef struct packed
	{
		float val;
		logic slow,
		      zero,
		      guard,
		      round,
		      sticky,
		      overflow,
		      sticky_last;
	} fpint_shiftl_round;

	typedef struct packed
	{
		float val;
		logic slow,
		      zero,
		      exp_step,
		      overflow;
	} fpint_round_rnorm;

	typedef struct packed
	{
		float val;
		logic slow,
		      zero,
		      overflow;
	} fpint_rnorm_encode;

	// Q22.10
	typedef logic[9:0]                                   fixed_frac;
	typedef logic[$bits(word) - $bits(fixed_frac) - 1:0] fixed_int;

	typedef struct packed signed
	{
		fixed_int  fint; // 'int' es una keyword
		fixed_frac frac;
	} fixed;

	localparam int FIXED_MULADD_DEPTH = 5;
	localparam int FIXED_DOTADD_DEPTH = 2 * FIXED_MULADD_DEPTH;

	localparam int SCHED_BRAM_WORDS = 2048; // 8KiB

	typedef word irq_lines;

endpackage
