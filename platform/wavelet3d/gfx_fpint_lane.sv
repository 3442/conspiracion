module gfx_fpint_lane
(
	input  logic      clk,

	input  gfx::float a,
	                  b,

	input  logic      mul_float_m1,
	                  unit_b_m1,
	                  float_a_1,
	                  int_hi_a_1,
	                  int_lo_a_1,
	                  zero_flags_1,
	                  zero_b_1,
	                  copy_flags_2,
	                  int_signed_4,
	                  copy_flags_5,
	                  int_operand_5,
	                  enable_norm_6,
	                  copy_flags_10,
	                  copy_flags_11,
	                  enable_round_11,
	                  encode_special_13,

	output gfx::float q
);

	import gfx::*;

	/* Notas de implementación para floating-point
	*
	* === PRODUCTO ===
	*
	* Queremos calcular q = a * b.
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
	 *
	 *
	 * === SUMA/RESTA ===
	 *
	 * Queremos calcular q = a + b. Curiosamente, eso es más complicado que a * b.
	 * Hay que ajustar el exponente del menor entre a y b para que coincida
	 * con el del mayor (desnormalizando), realizar la operación y finalmente
	 * renormalizar. Se hace suma o resta dependiendo de relaciones de signos,
	 * no según la operación de entrada (eso último solo le hace xor al signo de b).
	 * Recordar aquí que IEEE 754 es una especie de signo-magnitud y no complemento.
	 *
	 * En el caso de una resta, el exponente normalizado puede ser mucho más
	 * pequeño que cualquiera de los exponentes de entrada. Necesitamos
	 * entonces de lǵoica CLZ (count leading zeros) para renormalizar.
	 *
	 *
	 * === CONVERSIÓN INTEGER->FP ===
	 *
	 * Esto simplemente usa el mismo datapath de fadd, con el abs del entero
	 * como entrada como entrada de clz. El exponente de referencia se fija
	 * en 30 (aludiendo al segundo msb de un entero de 32 bits). A partir de
	 * ese punto es idéntico a un fadd, las etapas de clz se encargan de ajustar
	 * el exponente.
	 */

	logic exp_step, guard_0, guard_1, guard_2, guard_3, guard_4, guard_5, guard_10,
	      int_sign, lo_msb, lo_reduce, overflow_0, overflow_1, overflow_10, overflow_12,
	      round_0, round_1, round_2, round_3, round_4, round_5, round_10, sign_0,
	      sign_10, sign_11, sign_12, slow_1, slow_2, slow_3, slow_4, slow_5, slow_10,
	      slow_11, slow_12, slow_in_1, slow_in_next, slow_out, sticky_1, sticky_2,
	      sticky_3, sticky_4, sticky_5, sticky_10, sticky_last, zero_1, zero_2, zero_3,
	      zero_4, zero_5, zero_10, zero_11, zero_12;

	float a_add, a_m1, a_mul, b_add, b_0, b_m1, b_mul,
	      max_2, max_3, max_4, max_5, min_2, min_3, min_4;

	float_class a_class_0, a_class_1, b_class_0, b_class_1,
	            max_class_2, max_class_3, min_class_2, min_class_3, min_class_4;

	word add_sub, clz_in, normalized, product_hi, product_lo;
	dword product;
	float_exp exp, exp_11, exp_10, exp_12, exp_delta;
	float_mant mant_10, mant_11, mant_12;
	float_mant_full hi;
	logic[$bits(float_mant_full) - 3:0] lo;

	typedef logic[$bits(float_mant_full) + 1:0] extended_mant;
	localparam bit[$clog2($bits(extended_mant)):0] MAX_SHIFT = 1 << $clog2($bits(extended_mant));

	extended_mant max_mant, min_mant, sticky_mask;
	logic[$clog2(MAX_SHIFT):0] clz_shift, exp_shift;

	localparam int INT_SHIFT_REF   = $bits(word) - 2;
	localparam int SHIFT_WIDTH     = {{($bits(int) - $bits(MAX_SHIFT)){1'b0}}, MAX_SHIFT};
	localparam int CLZ_EXTEND_BITS = $bits(float_exp) - $bits(clz_shift) + 1;

	struct packed
	{
		float    max;
		logic    guard,
		         round,
		         slow,
		         sticky,
		         zero;
		word     add_sub;
	} clz_hold[FADD_CLZ_STAGES], clz_hold_out;

	gfx_clz #($bits(word)) clz
	(
		.clk(clk),
		.clz(clz_shift),
		.value(clz_in)
	);

	function extended_mant extend_min_max(float in, float_class in_class);
		extend_min_max = {~in_class.exp_min, in.mant, 2'b00};
	endfunction

	function word fp_add_sub_arg(extended_mant arg);
		fp_add_sub_arg = {1'b0, arg, {($bits(fp_add_sub_arg) - $bits(arg) - 1){1'b0}}};
	endfunction

	assign lo_msb = lo[$bits(lo) - 1];
	assign slow_out = &exp_12 || slow_12 || overflow_12;
	assign exp_delta = max_2.exp - min_2.exp;
	assign lo_reduce = |lo[$bits(lo) - 2:0];
	assign normalized = clz_hold_out.add_sub << clz_shift;
	assign clz_hold_out = clz_hold[FADD_CLZ_STAGES - 1];
	assign slow_in_next = is_float_special(a_class_0) | is_float_special(b_class_0);
	assign {product_hi, product_lo} = product;
	assign {hi, guard_0, round_0, lo} = product[2 * $bits(float_mant_full) - 1:0];

	always_comb begin
		clz_in = add_sub;
		if (~enable_norm_6)
			clz_in[$bits(clz_in) - 1:$bits(clz_in) - 2] = 2'b01;
	end

	always_ff @(posedge clk) begin
		// Stage -1: 

		a_m1 <= a;
		b_m1 <= b;
		a_mul <= a;
		b_mul <= b;

		/* Nótese que el orden es sign-exp-mant. Esto coloca el '1.' implícito
		 * en la posición correcta para multiplicar las mantisas.
		 */
		if (mul_float_m1) begin
			a_mul.exp <= 1;
			b_mul.exp <= 1;
			a_mul.sign <= 0;
			b_mul.sign <= 0;
		end

		if (unit_b_m1) begin
			b_mul.exp <= 0;
			b_mul.mant <= 1;
			b_mul.sign <= 0;
		end

		// Stage 0: multiplicación de fp o enteros

		b_0 <= b_m1;
		sign_0 <= a_m1.sign ^ b_m1.sign;
		product <= a_mul * b_mul;
		a_class_0 <= classify_float(a_m1);
		b_class_0 <= classify_float(b_m1);
		{overflow_0, exp} <= {1'b0, a_m1.exp} + {1'b0, b_m1.exp} - {1'b0, FLOAT_EXP_BIAS};

		// Stage 1: normalización

		if (float_a_1) begin
			slow_1 <= slow_in_next | (overflow_0 & ~a_class_0.exp_min & ~a_class_1.exp_min);
			zero_1 <= a_class_0.exp_min | b_class_0.exp_min;
		end else begin
			slow_1 <= 0;
			zero_1 <= 0;
		end

		overflow_1 <= 0;
		a_add.sign <= sign_0;

		if (hi[$bits(hi) - 1]) begin
			guard_1 <= guard_0;
			round_1 <= round_0;
			sticky_1 <= lo_msb | lo_reduce;
			a_add.mant <= implicit_mant(hi);
			{overflow_1, a_add.exp} <= {1'b0, exp} + 1;
		end else begin
			/* Bit antes de msb es necesariamente 1, ya que los msb de
			 * ambos multiplicandos son 1. Ver assert en implicit_mant().
			 */
			guard_1 <= round_0;
			round_1 <= lo[$bits(lo) - 1];
			sticky_1 <= lo_reduce;
			a_add.exp <= exp;
			a_add.mant <= implicit_mant({hi[$bits(hi) - 2:0], guard_0});
		end

		unique case (1'b1)
			float_a_1: ;

			int_hi_a_1:
				a_add <= product_hi;

			int_lo_a_1:
				a_add <= product_lo;
		endcase

		a_class_1 <= a_class_0;
		slow_in_1 <= slow_in_next;

		if (zero_flags_1) begin
			a_class_1 <= classify_float(0);
			slow_in_1 <= 0;
		end

		if (zero_b_1) begin
			b_add <= 0;
			b_class_1 <= classify_float(0);
		end else begin
			b_add <= b_0;
			b_class_1 <= b_class_0;
		end

		/* Stage 2: ordenar tal que abs(max) >= abs(min). Wiki dice:
		 *
		 * A property of the single- and double-precision formats is that
		 * their encoding allows one to easily sort them without using
		 * floating-point hardware, as if the bits represented sign-magnitude
		 * integers, although it is unclear whether this was a design
		 * consideration (it seems noteworthy that the earlier IBM hexadecimal
		 * floating-point representation also had this property for normalized
		 * numbers).
		 */
		if ({b_add.exp, b_add.mant} > {a_add.exp, a_add.mant}) begin
			max_2 <= b_add;
			min_2 <= a_add;
			max_class_2 <= b_class_1;
			min_class_2 <= a_class_1;
		end else begin
			max_2 <= a_add;
			min_2 <= b_add;
			max_class_2 <= a_class_1;
			min_class_2 <= b_class_1;
		end

		guard_2 <= guard_1;
		round_2 <= round_1;
		sticky_2 <= sticky_1;

		if (copy_flags_2) begin
			slow_2 <= slow_1 | overflow_1;
			zero_2 <= zero_1;
		end else begin
			slow_2 <= slow_in_1;
			zero_2 <= 0;
		end

		// Stage 3: exp_shift amount

		max_3 <= max_2;
		min_3 <= min_2;
		slow_3 <= slow_2;
		zero_3 <= zero_2;
		guard_3 <= guard_2;
		round_3 <= round_2;
		sticky_3 <= sticky_2;
		max_class_3 <= max_class_2;
		min_class_3 <= min_class_2;

		exp_shift <= exp_delta[$bits(exp_shift) - 1:0];
		if (exp_delta > {{($bits(exp_delta) - $bits(MAX_SHIFT)){1'b0}}, MAX_SHIFT})
			exp_shift <= MAX_SHIFT;

		// Stage 4: shifts y abs(max) para enteros con signo

		min_4 <= min_3;
		slow_4 <= slow_3;
		zero_4 <= zero_3;
		guard_4 <= guard_3;
		round_4 <= round_3;
		sticky_4 <= sticky_3;
		min_class_4 <= min_class_3;

		max_mant <= extend_min_max(max_3, max_class_3);
		min_mant <= extend_min_max(min_3, min_class_3) >> exp_shift;
		sticky_mask <= {($bits(min_mant)){1'b1}} << exp_shift;

		max_4 <= max_3;
		int_sign <= max_3[$bits(max_3) - 1];

		if (int_signed_4 & max_3[$bits(max_3) - 1])
			max_4 <= -max_3;

		// Stage 5: suma de mantisas

		max_5 <= max_4;
		slow_5 <= slow_4;
		zero_5 <= zero_4;
		guard_5 <= guard_4;
		round_5 <= round_4;

		if (int_operand_5) begin
			max_5.exp <= FLOAT_EXP_BIAS + INT_SHIFT_REF[$bits(float_exp) - 1:0];
			max_5.sign <= int_sign;
		end

		if (copy_flags_5)
			sticky_5 <= sticky_4;
		else
			sticky_5 <= |(extend_min_max(min_4, min_class_4) & ~sticky_mask);

		if (int_operand_5)
			add_sub <= max_4;
		else if (max_4.sign ^ min_4.sign)
			add_sub <= fp_add_sub_arg(max_mant) - fp_add_sub_arg(min_mant);
		else
			add_sub <= fp_add_sub_arg(max_mant) + fp_add_sub_arg(min_mant);

		// Stages 6-9: clz

		clz_hold[0].max <= max_5;
		clz_hold[0].slow <= slow_5;
		clz_hold[0].zero <= zero_5;
		clz_hold[0].guard <= guard_5;
		clz_hold[0].round <= round_5;
		clz_hold[0].sticky <= sticky_5;
		clz_hold[0].add_sub <= add_sub;

		for (int i = 1; i < FADD_CLZ_STAGES; ++i)
			clz_hold[i] <= clz_hold[i - 1];

		// Stage 10: normalización

		sign_10 <= clz_hold_out.max.sign;
		slow_10 <= clz_hold_out.slow;
		zero_10 <= clz_hold_out.zero;
		sticky_10 <= clz_hold_out.sticky;

		{mant_10, guard_10, round_10, sticky_last} <=
			normalized[$bits(normalized) - 2:$bits(normalized) - $bits(float_mant) - 4];

		{overflow_10, exp_10} <=
			{1'b0, clz_hold_out.max.exp} - {{CLZ_EXTEND_BITS{1'b0}}, clz_shift} + 1;

		if (clz_shift[$bits(clz_shift) - 1])
			zero_10 <= 1;

		if (copy_flags_10) begin
			guard_10 <= clz_hold_out.guard;
			round_10 <= clz_hold_out.round;
			sticky_last <= 0;
			overflow_10 <= 0;
		end

		// Stage 11: redondeo

		exp_11 <= exp_10;
		mant_11 <= mant_10;
		sign_11 <= sign_10;
		slow_11 <= slow_10 | (~copy_flags_11 & overflow_10 & ~zero_10);
		zero_11 <= zero_10;
		exp_step <= 0;

		// Este es el modo más común: round to nearest, ties to even
		if (enable_round_11 & guard_10 & (round_10 | sticky_10 | sticky_last | mant_10[0]))
			{exp_step, mant_11} <= {1'b0, mant_10} + 1;

		// Stage 12: ajuste de exponente por redondeo

		sign_12 <= sign_11;
		slow_12 <= slow_11;
		zero_12 <= zero_11;
		mant_12 <= mant_11;
		overflow_12 <= 0;

		if (exp_step)
			{overflow_12, exp_12} <= {1'b0, exp_11} + 1;
		else
			exp_12 <= exp_11;

		// Stage 13: ceros y NaNs

		q.exp <= exp_12;
		q.mant <= mant_12;
		q.sign <= sign_12;

		if (encode_special_13) begin
			if (slow_out) begin
				q.exp <= FLOAT_EXP_MAX;
				q.mant <= 1;
			end else if (zero_12) begin
				q.exp <= 0;
				q.mant <= 0;
			end
		end
	end

endmodule
