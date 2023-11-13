`include "gfx/gfx_defs.sv"

module gfx_frag
(
	input  logic         clk,
	                     rst_n,

	input  frag_xy_lanes fragments,
	input  paint_lanes   in_valid,
	output logic         in_ready,

	input  logic         out_ready,
	output logic         out_valid,
	output frag_paint    out
);

	logic funnel_valid;
	frag_xy funnel_frag;

	gfx_frag_funnel funnel
	(
		.frag(funnel_frag),
		.out_ready(frag_ready),
		.out_valid(funnel_valid),
		.*
	);

	logic frag_ready, frag_stall;

	gfx_pipeline_flow #(.STAGES(`GFX_FRAG_STAGES)) addr_flow
	(
		.stall(frag_stall),
		.in_ready(frag_ready),
		.in_valid(funnel_valid),
		.out_ready(1),
		.out_valid(),
		.*
	);

	linear_coord linear;

	gfx_frag_addr addr
	(
		.frag(funnel_frag),
		.stall(frag_stall),
		.*
	);

	localparam ADDR_WAIT_STAGES = `GFX_FRAG_STAGES - `GFX_FRAG_ADDR_STAGES;

	gfx_pipes #(.WIDTH($bits(linear_coord)), .DEPTH(ADDR_WAIT_STAGES)) addr_pipes
	(
		.in(linear),
		.out(),
		.stall(frag_stall),
		.*
	);

	fixed b1, b2;

	gfx_frag_bary bary
	(
		.ws(),
		.edges(),
		.stall(frag_stall),
		.*
	);

	gfx_frag_shade shade
	(
		.stall(frag_stall),
		.color(),
		.argb0(),
		.argb1_argb0(),
		.argb2_argb0(),
		.*
	);

endmodule
