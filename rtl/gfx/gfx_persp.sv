`include "gfx/gfx_defs.sv"

module gfx_persp
(
	input  logic       clk,
	                   rst_n,

	input  raster_xyzw in_vertex_a,
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

	// Perdón Ronald
	assign in_ready = out_ready;
	assign out_valid = in_valid;
	assign out_vertex_a = in_vertex_a;
	assign out_vertex_b = in_vertex_b;
	assign out_vertex_c = in_vertex_c;

/*
	logic stall;

	gfx_pipeline_flow #(.STAGES(`FIXED_DIV_STAGES)) flow
	(
		.*
	);

	gfx_persp_vertex persp_a
	(
		.in_vertex(in_vertex_a),
		.out_vertex(out_vertex_a),
		.*
	);

	gfx_persp_vertex persp_b
	(
		.in_vertex(in_vertex_b),
		.out_vertex(out_vertex_b),
		.*
	);

	gfx_persp_vertex persp_c
	(
		.in_vertex(in_vertex_c),
		.out_vertex(out_vertex_c),
		.*
	);
*/

endmodule
