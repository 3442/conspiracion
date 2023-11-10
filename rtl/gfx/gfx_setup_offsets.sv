`include "gfx/gfx_defs.sv"

module gfx_setup_offsets
(
	input  logic          clk,

	input  fixed          inc_x,
	                      inc_y,
	input  logic          stall,

	output raster_offsets offsets
);

	fixed x_hold[`GFX_RASTER_SIZE], y_hold[`GFX_RASTER_SIZE],
	      x_multiples[`GFX_RASTER_SIZE], y_multiples[`GFX_RASTER_SIZE];

	// Asume GFX_RASTER_BITS == 2. Los ceros deberían optimizarse trivialmente
	assign x_multiples[0] = 0;
	assign y_multiples[0] = 0;
	assign x_multiples[1] = inc_x;
	assign y_multiples[1] = inc_y;
	assign x_multiples[2] = inc_x << 1;
	assign y_multiples[2] = inc_y << 1;
	assign x_multiples[3] = (inc_x << 1) + inc_x;
	assign y_multiples[3] = (inc_y << 1) + inc_y;

	genvar i;
	generate
		for (i = 0; i < `GFX_RASTER_SIZE; ++i) begin: multiples
			always_ff @(posedge clk)
				if (!stall) begin
					x_hold[i] <= x_multiples[i];
					y_hold[i] <= y_multiples[i];
				end
		end

		for (i = 0; i < `GFX_RASTER_OFFSETS; ++i) begin: permutations
			always_ff @(posedge clk)
				if (!stall)
					offsets[i] <= x_hold[i % `GFX_RASTER_SIZE] + y_hold[i / `GFX_RASTER_SIZE];
		end
	endgenerate

endmodule
