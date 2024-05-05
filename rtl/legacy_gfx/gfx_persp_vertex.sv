`include "gfx/gfx_defs.sv"

module gfx_persp_vertex
(
	input  logic       clk,

	input  raster_xyzw in_vertex,
	input  logic       stall,

	output raster_xyzw out_vertex
);

	raster_xyzw skid_vertex;

	gfx_fixed_div x_div
	(
		.z(in_vertex.xy.x),
		.d(in_vertex.zw.w),
		.q(skid_vertex.xy.x),
		.*
	);

	gfx_fixed_div y_div
	(
		.z(in_vertex.xy.y),
		.d(in_vertex.zw.w),
		.q(skid_vertex.xy.y),
		.*
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`FIXED_DIV_STAGES)) z_pipes
	(
		.in(in_vertex.zw.z),
		.out(skid_vertex.zw.z),
		.*
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(`FIXED_DIV_STAGES)) w_pipes
	(
		.in(in_vertex.zw.w),
		.out(skid_vertex.zw.w),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(out_vertex))) vertex_skid
	(
		.in(skid_vertex),
		.out(out_vertex),
		.*
	);

endmodule
