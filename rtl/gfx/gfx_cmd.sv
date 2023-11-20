`include "gfx/gfx_defs.sv"

module gfx_cmd
(
	input  logic       clk,
	                   rst_n,

	input  cmd_addr    cmd_address,
	input  logic       cmd_read,
	                   cmd_write,
	input  cmd_word    cmd_writedata,
	output cmd_word    cmd_readdata,

	input  logic       vsync,

	output logic       swap_buffers,
	                   enable_clear,
	                   start_clear,
	output rgb24       clear_color,

	output logic       program_start,
	output cmd_word    program_header_base,
	                   program_header_size
);

	rgb24 next_clear_color;
	logic do_start_clear, next_start_clear, next_enable_clear, next_swap_buffers;

	struct packed
	{
		logic[4:0] mbz;
		logic      start_frame,
		           enable_clear,
		           swap_buffers;
		rgb24      clear_color;
	} readdata_scan, writedata_scan;

	assign cmd_readdata = readdata_scan;

	assign writedata_scan = cmd_writedata;
	assign readdata_scan.mbz = 0;
	assign readdata_scan.clear_color = clear_color;
	assign readdata_scan.enable_clear = enable_clear;
	assign readdata_scan.swap_buffers = swap_buffers;

	assign do_start_clear = writedata_scan.start_frame && writedata_scan.enable_clear;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			start_clear <= 0;
			enable_clear <= 0;
			swap_buffers <= 0;

			next_start_clear <= 0;
			next_enable_clear <= 0;
			next_swap_buffers <= 0;

			program_start <= 0;
		end else begin
			start_clear <= 0;
			program_start <= 0;

			if (vsync) begin
				start_clear <= next_start_clear;
				enable_clear <= next_enable_clear;
				swap_buffers <= next_swap_buffers;
			end

			if (cmd_write)
				unique case (cmd_address[1:0])
					`GFX_CMD_REG_ID: ;

					`GFX_CMD_REG_SCAN: begin
						next_enable_clear <= writedata_scan.enable_clear;
						next_swap_buffers <= writedata_scan.swap_buffers;

						if (!next_start_clear)
							next_start_clear <= do_start_clear;
					end

					`GFX_CMD_REG_HEADER_BASE: ;

					`GFX_CMD_REG_HEADER_SIZE:
						program_start <= 1;
				endcase
		end

	always_ff @(posedge clk) begin
		if (vsync)
			clear_color <= next_clear_color;

		if (cmd_write)
			unique case (cmd_address[1:0])
				`GFX_CMD_REG_ID: ;

				`GFX_CMD_REG_SCAN:
					next_clear_color <= writedata_scan.clear_color;

				`GFX_CMD_REG_HEADER_BASE:
					program_header_base <= cmd_writedata;

				`GFX_CMD_REG_HEADER_SIZE:
					program_header_size <= cmd_writedata;
			endcase
	end

endmodule
