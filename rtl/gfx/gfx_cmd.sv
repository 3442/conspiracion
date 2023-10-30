`include "gfx/gfx_defs.sv"

module gfx_cmd
(
	input  logic       clk,
	                   rst_n,

	input  logic[5:0]  cmd_address,
	input  logic       cmd_read,
	                   cmd_write,
	input  logic[31:0] cmd_writedata,
	output logic[31:0] cmd_readdata,

	input  logic       vsync,

	output logic       swap_buffers,
	                   enable_clear,
	output rgb24       clear_color
);

	struct packed
	{
		logic[5:0] mbz;
		logic      enable_clear,
		           swap_buffers;
		rgb24      clear_color;
	} readdata_scan, writedata_scan;

	assign readdata_scan.clear_color = clear_color;
	assign readdata_scan.mbz = 0;
	assign readdata_scan.enable_clear = enable_clear;
	assign readdata_scan.swap_buffers = swap_buffers;

	assign writedata_scan = cmd_writedata;

	assign cmd_readdata = readdata_scan;

	rgb24 next_clear_color;
	logic next_enable_clear, next_swap_buffers;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			enable_clear <= 0;
			swap_buffers <= 0;

			next_enable_clear <= 0;
			next_swap_buffers <= 0;
		end else begin
			if (vsync) begin
				enable_clear <= next_enable_clear;
				swap_buffers <= next_swap_buffers;
			end

			if (cmd_write) begin
				next_enable_clear <= writedata_scan.enable_clear;
				next_swap_buffers <= writedata_scan.swap_buffers;
			end
		end

	always_ff @(posedge clk) begin
		if (vsync)
			clear_color <= next_clear_color;

		if (cmd_write)
			next_clear_color <= writedata_scan.clear_color;
	end

endmodule
