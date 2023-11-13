`include "gfx/gfx_defs.sv"

module gfx_frag
(
	input  logic         clk,
	                     rst_n,

	input  frag_xy       frag,
	input  fixed_tri     bary,
	                     ws,
	input  logic         in_valid,
	output logic         in_ready,

	input  logic         out_ready,
	output logic         out_valid,
	output frag_paint    out
);

	logic stall;

	gfx_pipeline_flow #(.STAGES(`GFX_FRAG_STAGES)) addr_flow
	(
		.stall(stall),
		.*
	);

	linear_coord linear;

	gfx_frag_addr addr
	(
		.stall(stall),
		.*
	);

	localparam ADDR_WAIT_STAGES = `GFX_FRAG_STAGES - `GFX_FRAG_ADDR_STAGES;

	gfx_pipes #(.WIDTH($bits(linear_coord)), .DEPTH(ADDR_WAIT_STAGES)) addr_pipes
	(
		.in(linear),
		.out(),
		.stall(stall),
		.*
	);

	fixed b1, b2;

	gfx_frag_bary frag_bary
	(
		.stall(stall),
		.*
	);

	gfx_frag_shade shade
	(
		.stall(stall),
		.color(),
		.argb0(),
		.argb1_argb0(),
		.argb2_argb0(),
		.*
	);

endmodule
