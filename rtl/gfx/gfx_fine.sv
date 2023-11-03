`include "gfx/gfx_defs.sv"

module gfx_fine
#(parameter X=0, Y=0)
(
	input  logic     clk,

	input  raster_xy pos,
	input  fixed     corner_a,
	                 corner_b,
	                 corner_c,
	input  fixed     offsets_a[`GFX_RASTER_OFFSETS],
	                 offsets_b[`GFX_RASTER_OFFSETS],
	                 offsets_c[`GFX_RASTER_OFFSETS],
	input  logic     stall,

	output frag_xy   fragment,
	output logic     paint
);

	localparam INDEX = Y * `GFX_RASTER_SIZE + X;

	fixed edge_a, edge_b, edge_c, offset_a, offset_b, offset_c;
	logic sign_a, sign_b, sign_c;
	frag_xy fragment_hold;

	assign offset_a = offsets_a[INDEX];
	assign offset_b = offsets_b[INDEX];
	assign offset_c = offsets_c[INDEX];

	assign sign_a = edge_a[$bits(edge_a) - 1];
	assign sign_b = edge_b[$bits(edge_b) - 1];
	assign sign_c = edge_c[$bits(edge_c) - 1];

	always_ff @(posedge clk)
		if (!stall) begin
			paint <= !sign_a && !sign_b && !sign_c;
	
			fragment <= fragment_hold;
			fragment_hold.x <= pos.x.frag.num;
			fragment_hold.y <= pos.y.frag.num;

			edge_a <= corner_a + offset_a;
			edge_b <= corner_b + offset_b;
			edge_c <= corner_c + offset_c;
		end

endmodule
