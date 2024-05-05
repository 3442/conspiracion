`include "gfx/gfx_defs.sv"

module gfx_fix_floats
(
	input  logic       clk,
	                   rst_n,

	input  vec4        in_vertex_a,
	                   in_vertex_b,
	                   in_vertex_c,
	input  logic       in_valid,
	output logic       in_ready,

	input  logic       out_ready,
	output logic       out_valid,
	output raster_xyzw out_vertex_a,
	                   out_vertex_b,
	                   out_vertex_c
);

	logic stall;

	gfx_pipeline_flow #(.STAGES(`FP_FIX_STAGES + 1)) flow
	(
		.*
	);

	gfx_fix_vertex fix_a
	(
		.in_vertex(in_vertex_a),
		.out_vertex(out_vertex_a),
		.*
	);

	gfx_fix_vertex fix_b
	(
		.in_vertex(in_vertex_b),
		.out_vertex(out_vertex_b),
		.*
	);

	gfx_fix_vertex fix_c
	(
		.in_vertex(in_vertex_c),
		.out_vertex(out_vertex_c),
		.*
	);

endmodule
