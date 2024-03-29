`include "gfx/gfx_defs.sv"

module gfx
(
	input  logic          clk,
	                      rst_n,

	input  cmd_addr       cmd_address,
	input  logic          cmd_read,
	                      cmd_write,
	input  cmd_word       cmd_writedata,
	output cmd_word       cmd_readdata,

	input  logic          mem_waitrequest,
	                      mem_readdatavalid,
	input  vram_word      mem_readdata,
	output vram_byte_addr mem_address,
	output logic          mem_read,
	                      mem_write,
	output vram_word      mem_writedata,

	input  vram_addr      host_address,
	input  logic          host_read,
	                      host_write,
	input  vram_word      host_writedata,
	output logic          host_waitrequest,
	                      host_readdatavalid,
	output vram_word      host_readdata,

	input  logic          scan_ready,
	output logic          scan_valid,
	                      scan_endofpacket,
	                      scan_startofpacket,
	output rgb30          scan_data
);

	logic enable_clear, program_start, start_clear, swap_buffers;
	rgb24 clear_color;
	cmd_word fb_base_a, fb_base_b, program_header_base, program_header_size;

	gfx_cmd cmd
	(
		.*
	);

	logic batch_read, fetch_read, running, send_valid;
	lane_word send_data;
	lane_mask send_mask;
	vram_addr batch_address, fetch_address;

	gfx_sp sp
	(
		.*
	);

	logic send_ready, assembly_valid;
	fp_xyzw assembly_vertex_a, assembly_vertex_b, assembly_vertex_c;

	gfx_assembly assembly
	(
		.out_ready(fix_ready),
		.out_valid(assembly_valid),
		.out_vertex_a(assembly_vertex_a),
		.out_vertex_b(assembly_vertex_b),
		.out_vertex_c(assembly_vertex_c),
		.*
	);

	logic fix_ready, fix_valid;
	raster_xyzw fix_vertex_a, fix_vertex_b, fix_vertex_c;

	gfx_fix_floats fix
	(
		.in_ready(fix_ready),
		.in_valid(assembly_valid),
		.out_ready(persp_ready),
		.out_valid(fix_valid),
		.in_vertex_a(assembly_vertex_a),
		.in_vertex_b(assembly_vertex_b),
		.in_vertex_c(assembly_vertex_c),
		.out_vertex_a(fix_vertex_a),
		.out_vertex_b(fix_vertex_b),
		.out_vertex_c(fix_vertex_c),
		.*
	);

	logic persp_ready, persp_valid;
	raster_xyzw persp_vertex_a, persp_vertex_b, persp_vertex_c;

	gfx_persp perspective
	(
		.in_ready(persp_ready),
		.in_valid(fix_valid),
		.out_ready(raster_ready),
		.out_valid(persp_valid),
		.in_vertex_a(fix_vertex_a),
		.in_vertex_b(fix_vertex_b),
		.in_vertex_c(fix_vertex_c),
		.out_vertex_a(persp_vertex_a),
		.out_vertex_b(persp_vertex_b),
		.out_vertex_c(persp_vertex_c),
		.*
	);

	logic raster_ready;
	fixed_tri raster_ws;
	bary_lanes barys;
	paint_lanes raster_valid;
	frag_xy_lanes fragments;

	gfx_raster raster
	(
		.ws(raster_ws),
		.in_ready(raster_ready),
		.in_valid(persp_valid),
		.out_ready(funnel_ready),
		.out_valid(raster_valid),

		.vertex_a(persp_vertex_a),
		.vertex_b(persp_vertex_b),
		.vertex_c(persp_vertex_c),

		.*
	);

	logic frag_mask, scan_mask;
	vram_addr frag_base, scan_base;

	gfx_masks masks
	(
		.frag_mask_read_addr(),
		.*
	);

	logic frag_mask_set, frag_mask_write, frag_wait;
	linear_coord frag_mask_write_addr;

	gfx_clear clear
	(
		.*
	);

	logic funnel_ready, funnel_valid;
	frag_xy frag;
	fixed_tri frag_bary, frag_ws;

	gfx_funnel funnel
	(
		.in_ready(funnel_ready),
		.in_valid(raster_valid),
		.out_ready(frag_ready),
		.out_valid(funnel_valid),
		.*
	);

	logic frag_ready, frag_valid;
	frag_paint frag_out;

	gfx_frag frag_
	(
		.out(frag_out),

		.ws(frag_ws),
		.bary(frag_bary),
		.in_ready(frag_ready),
		.in_valid(funnel_valid),
		.out_ready(rop_ready),
		.out_valid(frag_valid),
		.*
	);

	logic rop_mask_assert, rop_ready, rop_write;
	vram_addr rop_address;
	vram_word rop_writedata;
	linear_coord rop_mask_addr;

	gfx_rop rop
	(
		.in(frag_out),
		.in_ready(rop_ready),
		.in_valid(frag_valid),
		.mask_addr(rop_mask_addr),
		.mask_assert(rop_mask_assert),
		.*
	);

	logic batch_readdatavalid, fb_readdatavalid, fetch_readdatavalid,
	      batch_waitrequest, fb_waitrequest, fetch_waitrequest, rop_waitrequest;

	vram_word batch_readdata, fb_readdata, fetch_readdata;

	gfx_mem mem
	(
		.*
	);

	logic fb_read, vsync;
	vram_addr fb_address;
	linear_coord scan_mask_addr;

	gfx_scanout scanout
	(
		.mask(scan_mask),
		.mask_addr(scan_mask_addr),
		.*
	);

endmodule
