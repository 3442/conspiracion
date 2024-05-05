// -> 4,4,4,4,4,4,4,4 -> 8,8,8,8 -> 16,16 -> 32
localparam int FPINT_CLZ_STAGES = 4;

localparam bit[$clog2($bits(gfx::float_mant_ext)):0] FPINT_MAX_SHIFT
	= 1 << $clog2($bits(gfx::float_mant_ext));

typedef logic[$clog2(FPINT_MAX_SHIFT):0] fpint_shift;

/* Las 15 etapas son:
 * - setup
 * - mulclass
 * - mnorm
 * - minmax
 * - expdiff
 * - shiftr
 * - addsub
 * - clz0-clz3
 * - shiftl
 * - round
 * - rnorm
 * - encode
 */

typedef struct
{
	gfx::float a,
	           b,
	           a_mul,
	           b_mul;
} fpint_setup_mulclass;

typedef struct
{
	gfx::float       b;
	gfx::float_exp   exp;
	gfx::float_class a_class,
	                 b_class;
	gfx::udword      product;
	logic            sign,
	                 overflow;
} fpint_mulclass_mnorm;

typedef struct
{
	gfx::float       a,
	                 b;
	gfx::float_class a_class,
	                 b_class;
	logic            slow,
	                 zero,
	                 guard,
	                 round,
	                 sticky,
	                 slow_in,
	                 overflow;
} fpint_mnorm_minmax;

typedef struct
{
	gfx::float       max,
	                 min;
	gfx::float_class max_class,
	                 min_class;
	logic            slow,
	                 zero,
	                 guard,
	                 round,
	                 sticky;
} fpint_minmax_expdiff;

typedef struct
{
	gfx::float       max,
	                 min;
	gfx::float_class max_class,
	                 min_class;
	fpint_shift      exp_shift;
	logic            slow,
	                 zero,
	                 guard,
	                 round,
	                 sticky;
} fpint_expdiff_shiftr;

typedef struct
{
	gfx::float          max,
	                    min;
	gfx::float_class    max_class,
	                    min_class;
	gfx::float_mant_ext max_mant,
	                    min_mant,
	                    sticky_mask;
	logic               slow,
	                    zero,
	                    guard,
	                    round,
	                    sticky,
	                    int_sign;
} fpint_shiftr_addsub;

typedef struct
{
	gfx::float max;
	gfx::word  add_sub;
	logic      slow,
	           zero,
	           guard,
	           round,
	           sticky;
} fpint_clz_hold;

typedef fpint_clz_hold fpint_addsub_clz;

typedef struct
{
	fpint_clz_hold hold;
	fpint_shift    shift;
} fpint_clz_shiftl;

typedef struct
{
	gfx::float val;
	logic      slow,
	           zero,
	           guard,
	           round,
	           sticky,
	           overflow,
	           sticky_last;
} fpint_shiftl_round;

typedef struct
{
	gfx::float val;
	logic      slow,
	           zero,
	           exp_step,
	           overflow;
} fpint_round_rnorm;

typedef struct
{
	gfx::float val;
	logic      slow,
	           zero,
	           overflow;
} fpint_rnorm_encode;

module gfx_shader_fpint
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  fpint_op          op,
	input  wave_exec         wave,
	input  logic             abort,
	                         in_valid,

	       gfx_regfile_io.ab read_data,

	       gfx_wb.tx         wb
);

	localparam int FPINT_STAGES = 7 + FPINT_CLZ_STAGES + 4;

	struct
	{
		fpint_op  op;
		wave_exec wave;
	} stage[FPINT_STAGES];

	logic stage_valid[FPINT_STAGES];

	assign wb.dest = stage[FPINT_STAGES - 1].wave.dest;
	assign wb.mask = 'x;
	assign wb.group = stage[FPINT_STAGES - 1].wave.group;
	assign wb.pc_add = 'x;
	assign wb.pc_inc = 1;
	assign wb.scalar = stage[FPINT_STAGES - 1].wave.dest_scalar;
	assign wb.pc_update = wb.writeback;
	assign wb.writeback = stage[FPINT_STAGES - 1].op.writeback;
	assign wb.mask_update = 0;

	// Ojo: stage_valid[0], pero stage[0] no
	assign stage_valid[0] = in_valid;

	genvar lane;
	generate
		for (lane = 0; lane < SHADER_LANES; ++lane) begin: lanes
			gfx_shader_fpint_lane unit
			(
				.clk(clk),
				.a(read_data.a[lane]),
				.b(read_data.b[lane]),
				.q(wb.lanes[lane]),
				.mul_float_0(op.setup_mul_float),
				.unit_b_0(op.setup_unit_b),
				.put_hi_2(stage[2 - 1].op.mnorm_put_hi),
				.put_lo_2(stage[2 - 1].op.mnorm_put_lo),
				.put_mul_2(stage[2 - 1].op.mnorm_put_mul),
				.zero_b_2(stage[2 - 1].op.mnorm_zero_b),
				.zero_flags_2(stage[2 - 1].op.mnorm_zero_flags),
				.abs_3(stage[3 - 1].op.minmax_abs),
				.swap_3(stage[3 - 1].op.minmax_swap),
				.zero_min_3(stage[3 - 1].op.minmax_zero_min),
				.copy_flags_3(stage[3 - 1].op.minmax_copy_flags),
				.int_signed_5(stage[5 - 1].op.shiftr_int_signed),
				.copy_flags_6(stage[6 - 1].op.addsub_copy_flags),
				.int_operand_6(stage[6 - 1].op.addsub_int_operand),
				.force_nop_7(stage[7 - 1].op.clz_force_nop),
				.copy_flags_11(stage[11 - 1].op.shiftl_copy_flags),
				.copy_flags_12(stage[12 - 1].op.round_copy_flags),
				.enable_12(stage[12 - 1].op.round_enable),
				.enable_14(stage[14 - 1].op.encode_enable)
			);
		end
	endgenerate

	always_ff @(posedge clk) begin
		stage[0].op <= op;
		stage[0].wave <= wave;

		for (int i = 1; i < FPINT_STAGES; ++i)
			stage[i] <= stage[i - 1];
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			for (int i = 1; i < FPINT_STAGES; ++i)
				stage_valid[i] <= 0;

			wb.valid <= 0;
		end else begin
			for (int i = 1; i < FPINT_STAGES; ++i)
				stage_valid[i] <= stage_valid[i - 1];

			// Se levanta 1 ciclo luego que in_valid
			stage_valid[2] <= stage_valid[1] & ~abort;

			wb.valid <= stage_valid[FPINT_STAGES - 1];
		end

endmodule

module gfx_shader_fpint_lane
import gfx::*;
(
	input  logic clk,

	input  word  a,
	             b,

	input  logic mul_float_0,
	             unit_b_0,
	             put_hi_2,
	             put_lo_2,
	             put_mul_2,
	             zero_b_2,
	             zero_flags_2,
	             abs_3,
	             swap_3,
	             zero_min_3,
	             copy_flags_3,
	             int_signed_5,
	             copy_flags_6,
	             int_operand_6,
	             force_nop_7,
	             copy_flags_11,
	             copy_flags_12,
	             enable_12,
	             enable_14,

	output word  q
);

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

	fpint_setup_mulclass setup_mulclass;
	fpint_mulclass_mnorm mulclass_mnorm;
	fpint_mnorm_minmax   mnorm_minmax;
	fpint_minmax_expdiff minmax_expdiff;
	fpint_expdiff_shiftr expdiff_shiftr;
	fpint_shiftr_addsub  shiftr_addsub;
	fpint_addsub_clz     addsub_clz;
	fpint_clz_shiftl     clz_shiftl;
	fpint_shiftl_round   shiftl_round;
	fpint_round_rnorm    round_rnorm;
	fpint_rnorm_encode   rnorm_encode;

	gfx_shader_fpint_setup stage_0
	(
		.clk(clk),
		.a(a),
		.b(b),
		.out(setup_mulclass),
		.unit_b(unit_b_0),
		.mul_float(mul_float_0)
	);

	gfx_shader_fpint_mulclass stage_1
	(
		.clk(clk),
		.in(setup_mulclass),
		.out(mulclass_mnorm)
	);

	gfx_shader_fpint_mnorm stage_2
	(
		.clk(clk),
		.in(mulclass_mnorm),
		.out(mnorm_minmax),
		.put_hi(put_hi_2),
		.put_lo(put_lo_2),
		.put_mul(put_mul_2),
		.zero_b(zero_b_2),
		.zero_flags(zero_flags_2)
	);

	gfx_shader_fpint_minmax stage_3
	(
		.clk(clk),
		.in(mnorm_minmax),
		.out(minmax_expdiff),
		.abs(abs_3),
		.swap(swap_3),
		.zero_min(zero_min_3),
		.copy_flags(copy_flags_3)
	);

	gfx_shader_fpint_expdiff stage_4
	(
		.clk(clk),
		.in(minmax_expdiff),
		.out(expdiff_shiftr)
	);

	gfx_shader_fpint_shiftr stage_5
	(
		.clk(clk),
		.in(expdiff_shiftr),
		.out(shiftr_addsub),
		.int_signed(int_signed_5)
	);

	gfx_shader_fpint_addsub stage_6
	(
		.clk(clk),
		.in(shiftr_addsub),
		.out(addsub_clz),
		.copy_flags(copy_flags_6),
		.int_operand(int_operand_6)
	);

	gfx_shader_fpint_clz stage_7_8_9_10
	(
		.clk(clk),
		.in(addsub_clz),
		.out(clz_shiftl),
		.force_nop(force_nop_7)
	);

	gfx_shader_fpint_shiftl stage_11
	(
		.clk(clk),
		.in(clz_shiftl),
		.out(shiftl_round),
		.copy_flags(copy_flags_11)
	);

	gfx_shader_fpint_round stage_12
	(
		.clk(clk),
		.in(shiftl_round),
		.out(round_rnorm),
		.enable(enable_12),
		.copy_flags(copy_flags_12)
	);

	gfx_shader_fpint_rnorm stage_13
	(
		.clk(clk),
		.in(round_rnorm),
		.out(rnorm_encode)
	);

	gfx_shader_fpint_encode stage_14
	(
		.clk(clk),
		.q(q),
		.in(rnorm_encode),
		.enable(enable_14)
	);

endmodule

// Stage 0: argumentos de mul
module gfx_shader_fpint_setup
import gfx::*;
(
	input  logic                clk,

	input  word                 a,
	                            b,
	input  logic                mul_float,
	                            unit_b,

	output fpint_setup_mulclass out
);

	always_ff @(posedge clk) begin
		out.a <= a;
		out.b <= b;
		out.a_mul <= a;
		out.b_mul <= b;

		/* Nótese que el orden es sign-exp-mant. Esto coloca el '1.' implícito
		 * en la posición correcta para multiplicar las mantisas.
		 */
		if (mul_float) begin
			out.a_mul.exp <= 1;
			out.b_mul.exp <= 1;
			out.a_mul.sign <= 0;
			out.b_mul.sign <= 0;
		end

		if (unit_b) begin
			out.b_mul.exp <= 0;
			out.b_mul.mant <= 1;
			out.b_mul.sign <= 0;
		end
	end

endmodule

// Stage 1: multiplicación de fp o enteros
module gfx_shader_fpint_mulclass
import gfx::*;
(
	input  logic                clk,

	input  fpint_setup_mulclass in,

	output fpint_mulclass_mnorm out
);

	always_ff @(posedge clk) begin
		out.b <= in.b;
		out.sign <= in.a.sign ^ in.b.sign;
		out.a_class <= classify_float(in.a);
		out.b_class <= classify_float(in.b);
		out.product <= in.a_mul * in.b_mul;
		{out.overflow, out.exp} <= {1'b0, in.a.exp} + {1'b0, in.b.exp} - {1'b0, FLOAT_EXP_BIAS};
	end

endmodule

// Stage 2: normalización
module gfx_shader_fpint_mnorm
import gfx::*;
(
	input  logic                clk,

	input  fpint_mulclass_mnorm in,
	input  logic                put_hi,
	                            put_lo,
	                            put_mul,
	                            zero_b,
	                            zero_flags,

	output fpint_mnorm_minmax   out
);

	word product_hi, product_lo;
	logic guard, lo_msb, lo_reduce, round, slow_in_next;
	float_mant_full hi;
	logic[$bits(float_mant_full) - 3:0] lo;

	assign lo_msb = lo[$bits(lo) - 1];
	assign lo_reduce = |lo[$bits(lo) - 2:0];
	assign slow_in_next = is_float_special(in.a_class) | is_float_special(in.b_class);
	assign {product_hi, product_lo} = in.product;
	assign {hi, guard, round, lo} = in.product[2 * $bits(float_mant_full) - 1:0];

	always_ff @(posedge clk) begin
		if (put_mul) begin
			out.slow <= slow_in_next | (in.overflow & ~in.a_class.exp_min & ~in.a_class.exp_min);
			out.zero <= in.a_class.exp_min | in.b_class.exp_min;
		end else begin
			out.slow <= 0;
			out.zero <= 0;
		end

		out.a.sign <= in.sign;
		out.overflow <= 0;

		if (hi[$bits(hi) - 1]) begin
			out.guard <= guard;
			out.round <= round;
			out.sticky <= lo_msb | lo_reduce;
			out.a.mant <= implicit_mant(hi);
			{out.overflow, out.a.exp} <= {1'b0, in.exp} + 1;
		end else begin
			/* Bit antes de msb es necesariamente 1, ya que los msb de
			 * ambos multiplicandos son 1. Ver assert en implicit_mant().
			 */
			out.guard <= round;
			out.round <= lo_msb;
			out.sticky <= lo_reduce;

			out.a.exp <= in.exp;
			out.a.mant <= implicit_mant({hi[$bits(hi) - 2:0], guard});
		end

		unique case (1'b1)
			put_mul: ;

			put_hi:
				out.a <= product_hi;

			put_lo:
				out.a <= product_lo;
		endcase

		out.a_class <= in.a_class;
		out.slow_in <= slow_in_next;

		if (zero_flags) begin
			out.a_class <= classify_float(0);
			out.slow_in <= 0;
		end

		if (zero_b) begin
			out.b <= 0;
			out.b_class <= classify_float(0);
		end else begin
			out.b <= in.b;
			out.b_class <= in.b_class;
		end
	end

endmodule

// Stage 3: ordenar tal que abs(max) >= abs(min)
module gfx_shader_fpint_minmax
import gfx::*;
(
	input  logic                clk,

	input  fpint_mnorm_minmax   in,
	input  logic                abs,
	                            swap,
	                            zero_min,
	                            copy_flags,

	output fpint_minmax_expdiff out
);

	logic abs_b_gt_abs_a, b_gt_a;

	/* Wiki dice:
	 *
	 * A property of the single- and double-precision formats is that
	 * their encoding allows one to easily sort them without using
	 * floating-point hardware, as if the bits represented sign-magnitude
	 * integers, although it is unclear whether this was a design
	 * consideration (it seems noteworthy that the earlier IBM hexadecimal
	 * floating-point representation also had this property for normalized
	 * numbers).
	 */
	assign abs_b_gt_abs_a = {in.b.exp, in.b.mant} > {in.a.exp, in.a.mant};

	always_comb begin
		unique case ({in.b.sign, in.a.sign})
			2'b00: b_gt_a = abs_b_gt_abs_a;
			2'b01: b_gt_a = 1;
			2'b10: b_gt_a = 0;
			2'b11: b_gt_a = abs_b_gt_abs_a;
		endcase

		if (abs)
			b_gt_a = abs_b_gt_abs_a;
	end

	always_ff @(posedge clk) begin
		if (b_gt_a ^ swap) begin
			out.max <= in.b;
			out.min <= in.a;
			out.max_class <= in.b_class;
			out.min_class <= in.a_class;
		end else begin
			out.max <= in.a;
			out.min <= in.b;
			out.max_class <= in.a_class;
			out.min_class <= in.b_class;
		end

		if (zero_min) begin
			out.min <= 0;
			out.min_class <= classify_float(0);
		end

		out.guard <= in.guard;
		out.round <= in.round;
		out.sticky <= in.sticky;

		if (copy_flags) begin
			out.slow <= in.slow | in.overflow;
			out.zero <= in.zero;
		end else begin
			out.slow <= in.slow_in;
			out.zero <= 0;
		end
	end

endmodule

// Stage 4: exp_shift amount
module gfx_shader_fpint_expdiff
import gfx::*;
(
	input  logic                clk,

	input  fpint_minmax_expdiff in,

	output fpint_expdiff_shiftr out
);

	float_exp exp_delta;

	assign exp_delta = in.max.exp - in.min.exp;

	always_ff @(posedge clk) begin
		out.max <= in.max;
		out.min <= in.min;
		out.slow <= in.slow;
		out.zero <= in.zero;
		out.guard <= in.guard;
		out.round <= in.round;
		out.sticky <= in.sticky;
		out.max_class <= in.max_class;
		out.min_class <= in.min_class;

		out.exp_shift <= exp_delta[$bits(out.exp_shift) - 1:0];
		if (exp_delta > {{($bits(exp_delta) - $bits(FPINT_MAX_SHIFT)){1'b0}}, FPINT_MAX_SHIFT})
			out.exp_shift <= FPINT_MAX_SHIFT;
	end

endmodule

// Stage 5: shifts y abs(max) para enteros con signo
module gfx_shader_fpint_shiftr
import gfx::*;
(
	input  logic                clk,

	input  fpint_expdiff_shiftr in,
	input  logic                int_signed,

	output fpint_shiftr_addsub  out
);

	always_ff @(posedge clk) begin
		out.min <= in.min;
		out.slow <= in.slow;
		out.zero <= in.zero;
		out.guard <= in.guard;
		out.round <= in.round;
		out.sticky <= in.sticky;
		out.min_class <= in.min_class;

		out.max_mant <= float_prepare_round(in.max, in.max_class);
		out.min_mant <= float_prepare_round(in.min, in.min_class) >> in.exp_shift;
		out.sticky_mask <= {($bits(out.min_mant)){1'b1}} << in.exp_shift;

		out.max <= in.max;
		out.int_sign <= in.max[$bits(in.max) - 1];

		if (int_signed & in.max[$bits(in.max) - 1])
			out.max <= -in.max;
	end

endmodule

// Stage 6: suma de mantisas
module gfx_shader_fpint_addsub
import gfx::*;
(
	input  logic               clk,

	input  fpint_shiftr_addsub in,
	input  logic               copy_flags,
	                           int_operand,

	output fpint_addsub_clz    out
);

	localparam int INT_SHIFT_REF = $bits(word) - 2;

	function word fp_add_sub_arg(float_mant_ext arg);
		fp_add_sub_arg = {1'b0, arg, {($bits(fp_add_sub_arg) - $bits(arg) - 1){1'b0}}};
	endfunction

	always_ff @(posedge clk) begin
		out.max <= in.max;
		out.slow <= in.slow;
		out.zero <= in.zero;
		out.guard <= in.guard;
		out.round <= in.round;

		if (int_operand) begin
			out.max.exp <= FLOAT_EXP_BIAS + INT_SHIFT_REF[$bits(float_exp) - 1:0];
			out.max.sign <= in.int_sign;
		end

		if (copy_flags)
			out.sticky <= in.sticky;
		else
			out.sticky <= |(float_prepare_round(in.min, in.min_class) & ~in.sticky_mask);

		if (int_operand)
			out.add_sub <= in.max;
		else if (in.max.sign ^ in.min.sign)
			out.add_sub <= fp_add_sub_arg(in.max_mant) - fp_add_sub_arg(in.min_mant);
		else
			out.add_sub <= fp_add_sub_arg(in.max_mant) + fp_add_sub_arg(in.min_mant);
	end

endmodule

// Stages 7-10: encontrar el 1 más significativo
module gfx_shader_fpint_clz
import gfx::*;
(
	input  logic            clk,

	input  fpint_addsub_clz in,
	input  logic            force_nop,

	output fpint_clz_shiftl out
);

	word clz_in;
	fpint_clz_hold hold[FPINT_CLZ_STAGES];

	assign out.hold = hold[FPINT_CLZ_STAGES - 1];

	gfx_clz #($bits(word)) clz
	(
		.clk(clk),
		.clz(out.shift),
		.value(clz_in)
	);

	always_comb begin
		clz_in = in.add_sub;
		if (force_nop)
			clz_in[$bits(clz_in) - 1:$bits(clz_in) - 2] = 2'b01;
	end

	always_ff @(posedge clk) begin
		hold[0] <= in;

		for (int i = 1; i < FPINT_CLZ_STAGES; ++i)
			hold[i] <= hold[i - 1];
	end

endmodule

// Stage 11: normalización
module gfx_shader_fpint_shiftl
import gfx::*;
(
	input  logic              clk,

	input  fpint_clz_shiftl   in,
	input  logic              copy_flags,

	output fpint_shiftl_round out
);

	localparam int CLZ_EXTEND_BITS = $bits(float_exp) - $bits(in.shift) + 1;

	word normalized;

	assign normalized = in.hold.add_sub << in.shift;

	always_ff @(posedge clk) begin
		out.slow <= in.hold.slow;
		out.zero <= in.hold.zero;
		out.sticky <= in.hold.sticky;
		out.val.sign <= in.hold.max.sign;

		{out.val.mant, out.guard, out.round, out.sticky_last} <=
			normalized[$bits(normalized) - 2:$bits(normalized) - $bits(float_mant) - 4];

		{out.overflow, out.val.exp} <=
			{1'b0, in.hold.max.exp} - {{CLZ_EXTEND_BITS{1'b0}}, in.shift} + 1;

		if (in.shift[$bits(in.shift) - 1])
			out.zero <= 1;

		if (copy_flags) begin
			out.guard <= in.hold.guard;
			out.round <= in.hold.round;
			out.overflow <= 0;
			out.sticky_last <= 0;
		end
	end

endmodule

// Stage 12: redondeo
module gfx_shader_fpint_round
import gfx::*;
(
	input  logic              clk,

	input  fpint_shiftl_round in,
	input  logic              copy_flags,
	                          enable,

	output fpint_round_rnorm  out
);

	always_ff @(posedge clk) begin
		out.val <= in.val;
		out.slow <= in.slow | (~copy_flags & in.overflow & ~in.zero);
		out.zero <= in.zero;
		out.exp_step <= 0;

		// Este es el modo de redondeo más usual: round to nearest, ties to even
		if (enable & in.guard & (in.round | in.sticky | in.sticky_last | in.val.mant[0]))
			{out.exp_step, out.val.mant} <= {1'b0, out.val.mant} + 1;
	end

endmodule

// Stage 13: ajuste de exponente por redondeo
module gfx_shader_fpint_rnorm
import gfx::*;
(
	input  logic              clk,

	input  fpint_round_rnorm  in,

	output fpint_rnorm_encode out
);

	always_ff @(posedge clk) begin
		out.slow <= in.slow;
		out.zero <= in.zero;
		out.overflow <= 0;
		out.val.mant <= in.val.mant;
		out.val.sign <= in.val.sign;

		if (in.exp_step)
			{out.overflow, out.val.exp} <= {1'b0, in.val.exp} + 1;
		else
			out.val.exp <= in.val.exp;
	end

endmodule

// Stage 14: salida y codificación de ceros y NaNs
module gfx_shader_fpint_encode
import gfx::*;
(
	input  logic              clk,

	input  fpint_rnorm_encode in,
	input  logic              enable,

	output float              q
);

	always_ff @(posedge clk) begin
		q <= in.val;

		if (enable) begin
			if (&in.val.exp | in.slow | in.overflow) begin
				q.exp <= FLOAT_EXP_MAX;
				q.mant <= 1;
			end else if (in.zero) begin
				q.exp <= 0;
				q.mant <= 0;
			end
		end
	end

endmodule
