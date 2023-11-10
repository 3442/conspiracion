`include "gfx/gfx_defs.sv"

module gfx_raster_fine
#(parameter X=0, Y=0)
(
	input  logic              clk,

	input  raster_xy          pos,
	input  fixed_tri          corners,
	input  raster_offsets_tri offsets,
	input  logic              stall,

	output frag_xy            fragment,
	output logic              paint
);

	localparam INDEX = Y * `GFX_RASTER_SIZE + X;

	frag_xy fragment_hold;
	fixed_tri edges, per_edge_offsets;
	logic[2:0] signs;
	raster_xy_prec prec;
	logic[`GFX_RASTER_BITS - 1:0] fine_x, fine_y;

	assign prec = pos;
	assign fine_x = X;
	assign fine_y = Y;

	always_comb
		for (integer i = 0; i < 3; ++i) begin
			signs[i] = edges[i][$bits(edges[0]) - 1];
			per_edge_offsets[i] = offsets[i][INDEX];
		end

	always_ff @(posedge clk)
		if (!stall) begin
			paint <= signs == 0;
	
			fragment <= fragment_hold;
			fragment_hold.x <= {prec.x.coarse, fine_x};
			fragment_hold.y <= {prec.y.coarse, fine_y};

			for (integer i = 0; i < 3; ++i)
				edges[i] <= corners[i] + per_edge_offsets[i];
		end

endmodule
