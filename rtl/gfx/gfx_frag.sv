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
		.out_ready(addr_ready),
		.out_valid(funnel_valid),
		.*
	);

	logic addr_ready, addr_stall;

	gfx_pipeline_flow #(.STAGES(`GFX_FRAG_ADDR_STAGES)) addr_flow
	(
		.stall(addr_stall),
		.in_ready(addr_ready),
		.in_valid(funnel_valid),
		.out_ready(1),
		.out_valid(),
		.*
	);

	gfx_frag_addr addr
	(
		.stall(addr_stall),

		.frag(funnel_frag),
		.linear(),
		.*
	);

endmodule
