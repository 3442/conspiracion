`include "gfx/gfx_defs.sv"

module gfx_fix_vertex
(
	input  logic       clk,

	input  vec4        in_vertex,
	input  logic       stall,

	output raster_xyzw out_vertex
);

	fixed x, y;
	raster_xyzw fixed_vertex, corrected;
	fixed[`FLOATS_PER_VEC - 1:0] fixed_vals, corrected_vals, skid_vals;

	assign out_vertex = skid_vals;
	assign fixed_vertex = fixed_vals;
	assign corrected_vals = corrected;

	assign x = fixed_vertex.xy.x;
	assign y = fixed_vertex.xy.y;

	genvar i;
	generate
		for (i = 0; i < `FLOATS_PER_VEC; ++i) begin: components
			gfx_fp_fix fix
			(
				.in(in_vertex[i]),
				.out(fixed_vals[i]),
				.*
			);

			gfx_skid_buf #(.WIDTH($bits(fixed))) skid
			(
				.in(corrected_vals[i]),
				.out(skid_vals[i]),
				.*
			);
		end
	endgenerate

	always_ff @(posedge clk)
		if (!stall) begin
			/*   x * `GFX_X_RES / 2
			 * = x * 320
			 * = x * 64 * 5
			 * = (x * 5) << 6
			 * = (x * (4 + 1)) << 6
			 * = ((x << 2) + x) << 6
			 *
			 *   y * `GFX_Y_RES / 2
			 * = y * 240
			 * = y * 16 * 15
			 * = (y * 15) << 4
			 * = (y * (16 - 1)) << 4
			 * = ((y << 4) - y) << 4
			 */
			corrected.zw <= fixed_vertex.zw;
			corrected.xy.x <= ((x << 2) + x) << 6;
			corrected.xy.y <= ((y << 4) - y) << 4;
		end

endmodule
