`include "gfx/gfx_defs.sv"

module gfx_frag_addr
(
	input  logic        clk,

	input  frag_xy      frag,
	input  logic        stall,

	output linear_coord linear
);

	/* frag está expresado en un rango normalizado con igual distribución
	 * entre positivos y negativos. Para obtener la dirección lineal que le
	 * corresponde, debemos corregir esto para que el mínimo sea cero en
	 * cada coordenada. Luego de eso,
	 *
	 *   linear = y_corregido * `GFX_X_RES + x_corregido
	 *
	 * Afortunadamente, esto no necesita una FMA, como procederé a demostrar:
	 *
	 *   y * `GFX_X_RES + x
	 * = y * 640 + x
	 * = y * 128 * 5 + x
	 * = ((y * 5) << 7) + x
	 * = ((y * (4 + 1)) << 7) + x
	 * = (((y << 2) + y) << 7) + x
	 * = (y << 9) + (y << 7) + x
	 *
	 * Para corregir x ([-320, 319]) se le suma `GFX_RES_X / 2.
	 *
	 * Para corregir y ([-240, 239]) se debe tomar en cuenta que las
	 * direcciones lineales incrementan hacia abajo, así que:
	 *   y_corregido = `GFX_RES_Y / 2 - 1 - y
	 */

	localparam ZERO_PAD = $bits(linear_coord) - $bits(xy_coord);

	// Estas constantes asumen `GFX_X_RES == 640
	localparam Y_SHIFT0 = 9, Y_SHIFT1 = 7;

	xy_coord bias_x, bias_y;
	linear_coord row_start, x_biased, x_hold, y_biased;

	assign bias_x = `GFX_X_RES / 2;
	assign bias_y = `GFX_Y_RES / 2 - 1;

	always_ff @(posedge clk)
		if (!stall) begin
			x_biased <= {{ZERO_PAD{1'b0}}, frag.x + bias_x};
			y_biased <= {{ZERO_PAD{1'b0}}, bias_y - frag.y};

			x_hold <= x_biased;
			row_start <= (y_biased << Y_SHIFT0) + (y_biased << Y_SHIFT1);

			linear <= row_start + x_hold;
		end

endmodule
