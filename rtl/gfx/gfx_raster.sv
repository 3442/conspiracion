`include "gfx/gfx_defs.sv"

module gfx_raster
(
	input  logic         clk,
	                     rst_n,

	input  raster_xy     vertex_a,
	                     vertex_b,
	                     vertex_c,
	input  logic         in_valid,
	output logic         in_ready,

	output frag_xy_lanes fragments,
	output bary_lanes    barys,
	input  logic         out_ready,
	output paint_lanes   out_valid
);

	logic setup_stall, setup_valid;

	gfx_pipeline_flow #(.STAGES(`GFX_SETUP_STAGES)) setup_flow
	(
		.stall(setup_stall),
		.out_ready(coarse_ready),
		.out_valid(setup_valid),
		.*
	);

	fixed_tri coarse_x_offsets, coarse_y_offsets, coarse_test_offsets, edge_refs;
	raster_xy pos_ref;
	coarse_dim span_x, span_y;
	raster_offsets_tri offsets; //TODO: fsm con esto holdeado

	gfx_setup setup
	(
		.stall(setup_stall),
		.*
	);

	logic coarse_ready, coarse_valid;
	fixed_tri coarse_corners;
	raster_xy coarse_pos;

	gfx_raster_coarse coarse
	(
		.in_valid(setup_valid),
		.in_ready(coarse_ready),
		.out_ready(fine_ready),
		.out_valid(coarse_valid),
		.pos(coarse_pos),
		.corners(coarse_corners),
		.*
	);

	logic fine_ready, fine_stall, fine_valid;

	always_comb
		for (integer i = 0; i < `GFX_FINE_LANES; ++i)
			out_valid[i] = fine_valid && skid_paint_ij[i];

	gfx_pipeline_flow #(.STAGES(`GFX_FINE_STAGES)) fine_flow
	(
		.stall(fine_stall),
		.in_ready(fine_ready),
		.in_valid(coarse_valid),
		.out_ready(out_ready || !(|skid_paint_ij)),
		.out_valid(fine_valid),
		.*
	);

	frag_xy fragment_ij[`GFX_RASTER_SIZE][`GFX_RASTER_SIZE];
	fixed_tri barys_ij[`GFX_RASTER_SIZE][`GFX_RASTER_SIZE];
	logic[`GFX_FINE_LANES - 1:0] paint_ij, skid_paint_ij;

	gfx_skid_buf #(.WIDTH(`GFX_FINE_LANES)) skid_paint
	(
		.in(paint_ij),
		.out(skid_paint_ij),
		.stall(fine_stall),
		.*
	);

	genvar i, j;
	generate
		for (i = 0; i < `GFX_RASTER_SIZE; ++i) begin: fine_x
			for (j = 0; j < `GFX_RASTER_SIZE; ++j) begin: fine_y
				gfx_raster_fine #(.X(i), .Y(j)) fine
				(
					.stall(fine_stall),

					.pos(coarse_pos),
					.corners(coarse_corners),

					.barys(barys_ij[i][j]),
					.paint(paint_ij[j * `GFX_RASTER_SIZE + i]),
					.fragment(fragment_ij[i][j]),
					.*
				);

				gfx_skid_buf #(.WIDTH($bits(frag_xy))) skid_fragment
				(
					.in(fragment_ij[i][j]),
					.out(fragments[j * `GFX_RASTER_SIZE + i]),
					.stall(fine_stall),
					.*
				);

				gfx_skid_buf #(.WIDTH($bits(fixed_tri))) skid_barys
				(
					.in(barys_ij[i][j]),
					.out(barys[j * `GFX_RASTER_SIZE + i]),
					.stall(fine_stall),
					.*
				);
			end
		end
	endgenerate

endmodule
