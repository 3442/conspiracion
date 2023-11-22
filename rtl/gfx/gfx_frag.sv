`include "gfx/gfx_defs.sv"

module gfx_frag
(
	input  logic      clk,
	                  rst_n,

	input  frag_xy    frag,
	input  fixed_tri  bary,
	                  ws,
	input  logic      in_valid,
	output logic      in_ready,

	input  logic      out_ready,
	output logic      out_valid,
	output frag_paint out
);

	logic stall;
	frag_paint frag_out;

	gfx_pipeline_flow #(.STAGES(`GFX_FRAG_STAGES)) addr_flow
	(
		.*
	);

	linear_coord linear;

	gfx_frag_addr addr
	(
		.*
	);

	localparam ADDR_WAIT_STAGES = `GFX_FRAG_STAGES - `GFX_FRAG_ADDR_STAGES;

	gfx_pipes #(.WIDTH($bits(linear_coord)), .DEPTH(ADDR_WAIT_STAGES)) addr_pipes
	(
		.in(linear),
		.out(frag_out.addr),
		.*
	);

	fixed b1, b2;

	gfx_frag_bary frag_bary
	(
		.*
	);

	color_lerp_lanes argb0, argb1_argb0, argb2_argb0;

	assign argb0[3] = 32'd0 << 8;
	assign argb0[2] = 32'd255 << 8;
	assign argb0[1] = 32'd0 << 8;
	assign argb0[0] = 32'd0 << 8;

	assign argb1_argb0[3] = 32'd0 << 8;
	assign argb1_argb0[2] = (-32'sd255) << 8;
	assign argb1_argb0[1] = 32'd255 << 8;
	assign argb1_argb0[0] = 32'd0 << 8;

	assign argb2_argb0[3] = 32'd0 << 8;
	assign argb2_argb0[2] = (-32'sd255) << 8;
	assign argb2_argb0[1] = 32'd0 << 8;
	assign argb2_argb0[0] = 32'd255 << 8;

	gfx_frag_shade shade
	(
		.color(frag_out.color),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(frag_out))) skid
	(
		.in(frag_out),
		.*
	);

endmodule
