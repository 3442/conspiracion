`include "gfx/gfx_defs.sv"

module gfx_setup_edge
(
	input  logic     clk,

	input  raster_xy p,
	                 q,
	                 origin,
	input  logic     stall,

	output fixed     base,
	                 inc_x,
	                 inc_y
);

	fixed delta_x, delta_y, hold_inc_x, hold_inc_y;

	gfx_pipes #(.WIDTH($bits(inc_x)), .DEPTH(`FIXED_FMA_DOT_STAGES)) inc_x_pipes
	(
		.in(hold_inc_x),
		.out(inc_x),
		.*
	);

	gfx_pipes #(.WIDTH($bits(inc_y)), .DEPTH(`FIXED_FMA_DOT_STAGES)) inc_y_pipes
	(
		.in(hold_inc_y),
		.out(inc_y),
		.*
	);

	gfx_fixed_fma_dot edge_base
	(
		.c(0),
		.q(base),
		.a0(delta_x),
		.b0(hold_inc_x),
		.a1(delta_y),
		.b1(hold_inc_y),
		.*
	);

	always_ff @(posedge clk)
		if (!stall) begin
			delta_x <= origin.x - q.x;
			delta_y <= origin.y - q.y;

			hold_inc_x <= p.y - q.y;
			hold_inc_y <= q.x - p.x;
		end

endmodule
