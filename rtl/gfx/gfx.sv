`include "gfx/gfx_defs.sv"

module gfx
(
	input  logic       clk,
	                   rst_n,

	input  logic[5:0]  cmd_address,
	input  logic       cmd_read,
	                   cmd_write,
	input  logic[31:0] cmd_writedata,
	output logic[31:0] cmd_readdata,

	input  logic       mem_waitrequest,
	                   mem_readdatavalid,
	input  logic[15:0] mem_readdata,
	output logic[25:0] mem_address,
	output logic       mem_read,
	                   mem_write,
	output logic[15:0] mem_writedata,

	input  logic       scan_ready,
	output logic       scan_valid,
	                   scan_endofpacket,
	                   scan_startofpacket,
	output rgb30       scan_data
);

	logic enable_clear, start_clear, swap_buffers;
	rgb24 clear_color;

	gfx_cmd cmd
	(
		.*
	);

	logic frag_mask, scan_mask;

	gfx_masks masks
	(
		.frag_mask_read_addr(),
		.*
	);

	logic raster_ready;
	bary_lanes barys;
	paint_lanes raster_valid;
	frag_xy_lanes fragments;

	gfx_raster raster
	(
		.in_ready(raster_ready),
		.in_valid(0), //TODO
		.out_ready(frag_ready),
		.out_valid(raster_valid),

		.vertex_a(), //TODO
		.vertex_b(), //TODO
		.vertex_c(), //TODO

		.*
	);

	logic frag_mask_set, frag_mask_write, frag_wait;
	linear_coord frag_mask_write_addr;

	gfx_clear clear
	(
		.rop_mask_addr(),
		.rop_mask_assert(0),
		.*
	);

	logic frag_ready, frag_valid;
	frag_paint frag_out;

	gfx_frag frag
	(
		.in_ready(frag_ready),
		.in_valid(raster_valid),
		.out_ready(1), //TODO
		.out_valid(frag_valid),

		.out(frag_out),
		.*
	);

	logic scanout_read_tmp, vsync;
	linear_coord scan_mask_addr;

	gfx_scanout scanout
	(
		.mask(scan_mask),
		.mask_addr(scan_mask_addr),

		.fb_read(scanout_read_tmp),
		.fb_address(),
		.fb_readdata(),
		.fb_waitrequest(0),
		.fb_readdatavalid(scanout_read_tmp),

		.*
	);

endmodule
