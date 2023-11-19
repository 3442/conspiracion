`include "gfx/gfx_defs.sv"

module gfx_scanout_dac
(
	input  logic     clk,
	                 rst_n,

	input  logic     enable_clear,
	input  rgb24     clear_color,

	input  logic     mask_fifo_out,
	input  vram_word fb_fifo_out,
	input  logic     in_valid,
	output logic     in_ready,

	input  logic     scan_ready,
	output logic     scan_valid,
	                 scan_endofpacket,
	                 scan_startofpacket,
	output rgb30     scan_data,

	output logic     vsync
);

	logic dac_valid, half, half_mask, stall, endofpacket, startofpacket;
	rgb24 pixel;
	rgb32 fifo_pixel;
	vram_word msw, lsw;
	half_coord next_addr;
	linear_coord max_addr, pixel_addr;

	struct packed
	{
		logic endofpacket,
		      startofpacket;
		rgb30 pixel;
	} skid_in, skid_out;

	assign scan_data = skid_out.pixel;
	assign scan_endofpacket = skid_out.endofpacket;
	assign scan_startofpacket = skid_out.startofpacket;

	assign max_addr = `GFX_X_RES * `GFX_Y_RES - 1;

	assign fifo_pixel = {msw, lsw};
	assign skid_in.endofpacket = endofpacket;
	assign skid_in.startofpacket = startofpacket;

	function color10 dac_color(color8 in);
		dac_color = {in, {2{in[0]}}};
	endfunction

	always_comb begin
		// Descarta fifo_pixel.a
		pixel.r = fifo_pixel.r;
		pixel.g = fifo_pixel.g;
		pixel.b = fifo_pixel.b;

		if (!half_mask)
			pixel = clear_color;

		/* Esto no puede ir en assigns. Funciona en Verilator pero causa ub en
		 * la netlist de Quartus. Eso no está documentado y perdí muchas horas.
		 */
		skid_in.pixel.r = dac_color(pixel.r);
		skid_in.pixel.g = dac_color(pixel.g);
		skid_in.pixel.b = dac_color(pixel.b);
	end

	gfx_skid_flow flow
	(
		.in_valid(dac_valid),
		.out_ready(scan_ready),
		.out_valid(scan_valid),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(skid_in))) skid
	(
		.in(skid_in),
		.out(skid_out),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			half <= 0;
			vsync <= 0;
			dac_valid <= 0;
			pixel_addr <= 0;
		end else begin
			vsync <= 0;
			if (in_ready && dac_valid) begin
				vsync <= skid_in.endofpacket;
				dac_valid <= 0;
			end

			if (in_ready && in_valid) begin
				half <= !half;
				dac_valid <= half;

				if (half) begin
					pixel_addr <= pixel_addr + 1;
					if (pixel_addr == max_addr)
						pixel_addr <= 0;
				end
			end
		end

	always_ff @(posedge clk)
		if (in_ready && in_valid) begin
			lsw <= msw;
			msw <= fb_fifo_out;
			half_mask <= mask_fifo_out;

			endofpacket <= pixel_addr == max_addr;
			startofpacket <= pixel_addr == 0;
		end

endmodule
