`include "gfx/gfx_defs.sv"

module gfx_setup
(
	input  logic              clk,

	input  raster_xy          vertex_a,
				              vertex_b,
	                          vertex_c,
	input  logic              stall,

	output raster_xy          pos_ref,
	output coarse_dim         span_x,
	                          span_y,
	output raster_offsets_tri offsets,
	output fixed_tri          edge_refs,
	                          coarse_x_offsets,
	                          coarse_y_offsets,
	                          coarse_test_offsets
);

	// FIXME FIXME FIXME: Top-left rule

	fixed_tri edge_base, edge_inc_x, edge_inc_y, out_edge_refs, x_offsets, y_offsets, test_offsets;

	raster_xy bounds_ref, hold_vertex_a, hold_vertex_b, hold_vertex_c, ps[3], qs[3], out_pos_ref;
	coarse_dim bounds_span_x, bounds_span_y, out_span_x, out_span_y;
	raster_offsets_tri out_offsets;

	struct packed
	{
		raster_xy          pos_ref;
		coarse_dim         span_x,
		                   span_y;
		raster_offsets_tri offsets;
		fixed_tri          edge_refs,
		                   coarse_x_offsets,
		                   coarse_y_offsets,
		                   coarse_test_offsets;
	} out, skid_out;

	gfx_skid_buf #(.WIDTH($bits(out))) skid
	(
		.in(out),
		.out(skid_out),
		.*
	);

	assign out.span_x = out_span_x;
	assign out.span_y = out_span_y;
	assign out.pos_ref = out_pos_ref;
	assign out.offsets = out_offsets;
	assign out.edge_refs = out_edge_refs;
	assign out.coarse_x_offsets = x_offsets;
	assign out.coarse_y_offsets = y_offsets;
	assign out.coarse_test_offsets = test_offsets;

	assign span_x = skid_out.span_x;
	assign span_y = skid_out.span_y;
	assign pos_ref = skid_out.pos_ref;
	assign offsets = skid_out.offsets;
	assign edge_refs = skid_out.edge_refs;
	assign coarse_x_offsets = skid_out.coarse_x_offsets;
	assign coarse_y_offsets = skid_out.coarse_y_offsets;
	assign coarse_test_offsets = skid_out.coarse_test_offsets;

	assign ps[0] = hold_vertex_a;
	assign qs[0] = hold_vertex_b;

	assign ps[1] = hold_vertex_b;
	assign qs[1] = hold_vertex_c;

	assign ps[2] = hold_vertex_c;
	assign qs[2] = hold_vertex_a;

	gfx_pipes #(.WIDTH($bits(vertex_a)), .DEPTH(`GFX_SETUP_BOUNDS_STAGES)) vertex_a_pipes
	(
		.in(vertex_a),
		.out(hold_vertex_a),
		.*
	);

	gfx_pipes #(.WIDTH($bits(vertex_b)), .DEPTH(`GFX_SETUP_BOUNDS_STAGES)) vertex_b_pipes
	(
		.in(vertex_b),
		.out(hold_vertex_b),
		.*
	);

	gfx_pipes #(.WIDTH($bits(vertex_c)), .DEPTH(`GFX_SETUP_BOUNDS_STAGES)) vertex_c_pipes
	(
		.in(vertex_c),
		.out(hold_vertex_c),
		.*
	);

	gfx_setup_bounds bounds
	(
		.span_x(bounds_span_x),
		.span_y(bounds_span_y),
		.reference(bounds_ref),
		.*
	);

	localparam POST_BOUNDS_DEPTH = `GFX_SETUP_EDGE_STAGES + `GFX_SETUP_OFFSETS_STAGES;

	gfx_pipes #(.WIDTH($bits(pos_ref)), .DEPTH(POST_BOUNDS_DEPTH)) ref_pipes
	(
		.in(bounds_ref),
		.out(out_pos_ref),
		.*
	);

	gfx_pipes #(.WIDTH($bits(span_x)), .DEPTH(POST_BOUNDS_DEPTH)) span_x_pipes
	(
		.in(bounds_span_x),
		.out(out_span_x),
		.*
	);

	gfx_pipes #(.WIDTH($bits(span_y)), .DEPTH(POST_BOUNDS_DEPTH)) span_y_pipes
	(
		.in(bounds_span_y),
		.out(out_span_y),
		.*
	);

	always_comb
		for (integer i = 0; i < 3; ++i)
			// Imaginárselo
			unique case ({x_offsets[i][$bits(fixed) - 1], y_offsets[i][$bits(fixed) - 1]})
				2'b00:
					test_offsets[i] = out_offsets[i][`GFX_RASTER_OFFSETS - 1];

				2'b01:
					test_offsets[i] = out_offsets[i][`GFX_RASTER_SIZE - 1];

				2'b10:
					test_offsets[i] = out_offsets[i][`GFX_RASTER_OFFSETS - `GFX_RASTER_SIZE - 1];

				2'b11:
					test_offsets[i] = out_offsets[i][0];
			endcase

	genvar i;
	generate
		for (i = 0; i < 3; ++i) begin: edges
			gfx_setup_edge edge_fn
			(
				.p(ps[i]),
				.q(qs[i]),
				.base(edge_base[i]),
				.inc_x(edge_inc_x[i]),
				.inc_y(edge_inc_y[i]),
				.origin(bounds_ref),
				.*
			);

			gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`GFX_SETUP_OFFSETS_STAGES)) base_pipes
			(
				.in(edge_base[i]),
				.out(out_edge_refs[i]),
				.*
			);

			gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`GFX_SETUP_OFFSETS_STAGES)) coarse_x_pipes
			(
				.in(edge_inc_x[i] << `GFX_RASTER_BITS),
				.out(x_offsets[i]),
				.*
			);

			gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`GFX_SETUP_OFFSETS_STAGES)) coarse_y_pipes
			(
				.in(edge_inc_y[i] << `GFX_RASTER_BITS),
				.out(y_offsets[i]),
				.*
			);

			gfx_setup_offsets edge_offsets
			(
				.inc_x(edge_inc_x[i]),
				.inc_y(edge_inc_y[i]),
				.offsets(out_offsets[i]),
				.*
			);
		end
	endgenerate

endmodule
