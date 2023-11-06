`include "gfx/gfx_defs.sv"

/* Operación a * b + c en punto fijo, diseñada para cerrar timing fácilmente
 * en Cyclone V donde los bloques de DSP soportan 18x18. Las etapas son:
 * - fma_ab: Productos de permutaciones a_lo/hi con b_lo/hi
 * - fma_pp: Recombinación en FMAs parciales
 * - fma_lo: Mitad baja del resultado y mitad alta pre-carry
 * - fma_hi: Mitad alta post-carry
 *
 * Nótese que esto toma exactamente el mismo trabajo que a * b
 * (ver rtl/core/mul.sv en proyecto 2 de arqui 1).
 */
module gfx_fixed_fma
(
	input  logic clk,

	input  fixed a,
	             b,
	             c,
	input  logic stall,

	output fixed q
);

	fixed a_ab, b_ab, c_ab, c_pp;
	logic[1:0] carry;
	logic[16:0] lo_left, lo_right;
	logic[17:0] lo_with_carry;
	logic[35:0] ab_ll, ab_lh, ab_hl, ab_hh;

	logic[15:0] a_lo, a_hi, b_lo, b_hi, ab_ll_hi, ab_ll_lo, ab_hl_hi, ab_hl_lo,
	            ab_lh_hi, ab_lh_lo, ab_hh_hi, ab_hh_lo, c_hi, c_lo, hi, hi_left, hi_right, lo;

	assign {a_hi, a_lo} = a_ab;
	assign {b_hi, b_lo} = b_ab;
	assign {c_hi, c_lo} = c_pp;

	assign {ab_ll_hi, ab_ll_lo} = ab_ll[31:0];
	assign {ab_lh_hi, ab_lh_lo} = ab_lh[31:0];
	assign {ab_hl_hi, ab_hl_lo} = ab_hl[31:0];
	assign {ab_hh_hi, ab_hh_lo} = ab_hh[31:0];

	assign {carry, lo} = lo_with_carry;

	always @(posedge clk)
		if (!stall) begin
			a_ab <= a;
			b_ab <= b;
			c_ab <= c;

			/* Como los operandos son pequeños (16 bits), esto no se sintetiza,
			 * sino que se enruta a través de los bloques de DSP más cercanos
			 */
			ab_ll <= {2'd0, a_lo} * {2'd0, b_lo};
			ab_lh <= {2'd0, a_lo} * {2'd0, b_hi};
			ab_hl <= {2'd0, a_hi} * {2'd0, b_lo};
			ab_hh <= {2'd0, a_hi} * {2'd0, b_hi};

			c_pp <= c_ab;

			hi_left <= ab_hh_lo + ab_lh_hi;
			lo_left <= {1'd0, ab_lh_lo} + {1'd0, ab_hl_lo};
			hi_right <= ab_hl_hi + c_hi;
			lo_right <= {1'd0, ab_ll_hi} + {1'd0, c_lo};

			hi <= hi_left + hi_right;
			lo_with_carry <= {1'd0, lo_left} + {1'd0, lo_right};

			q <= {hi + {14'd0, carry}, lo};
		end

endmodule
