`include "gfx/gfx_defs.sv"

module gfx_scanout
(
	input  logic        clk,
	                    rst_n,

	input  logic        enable_clear,
	input  rgb24        clear_color,

	input  logic        mask,
	output linear_coord mask_addr,

	input  logic        fb_waitrequest,
	                    fb_readdatavalid,
	input  mem_word     fb_readdata,
	output logic        fb_read,
	output half_coord   fb_address,

	input  logic        scan_ready,
	output logic        scan_valid,
	                    scan_endofpacket,
	                    scan_startofpacket,
	output rgb30        scan_data,

	output logic        vsync
);

	logic commit, effective_mask, flush, mask_fifo_out, dac_ready,
	      fb_ready, mask_fifo_ready, fb_fifo_valid, mask_fifo_valid,
	      pop, put, put_mask, next_vsync, start_vsync, wait_vsync;

	mem_word fb_fifo_out;
	half_coord commit_addr, mask_in_addr, mask_out_addr, mask_hold_addr, max_addr;

	assign mask_addr = mask_in_addr[$bits(mask_in_addr) - 1:$bits(mask_in_addr) - $bits(mask_addr)];
	assign max_addr[0] = 1;
	assign max_addr[$bits(max_addr) - 1:1] = `GFX_X_RES * `GFX_Y_RES - 1;

	assign fb_ready = !fb_read || !fb_waitrequest;
	assign next_vsync = commit && start_vsync;
	assign start_vsync = mask_hold_addr == max_addr;
	assign effective_mask = mask || !enable_clear;

	gfx_flush_flow #(.STAGES(`GFX_MASK_STAGES)) mask_flow
	(
		.in_valid(!wait_vsync),
		.out_ready(fb_ready && mask_fifo_ready && !next_vsync),
		.out_valid(pop),
		.*
	);

	gfx_pipes #(.WIDTH($bits(mask_in_addr)), .DEPTH(`GFX_MASK_STAGES)) addr_pipes
	(
		.in(mask_in_addr),
		.out(mask_out_addr),
		.stall(0),
		.*
	);

	/* Estas FIFOs deben cumplir dos propiedades para garantizar correctitud:
	 *
	 * 1. mask_fifo.out_ready && mask_fifo.out_valid <=> scan.in_ready && scan.in_valid
	 * 2. fb_fifo.out_ready && fb_fifo.out_valid => scan.in_ready && scan.in_valid
	 *
	 * Nótese la asimetría (<=> vs =>), debido a mask_fifo.out
	 */

	gfx_fifo #(.WIDTH($bits(effective_mask)), .DEPTH(`GFX_SCANOUT_FIFO_DEPTH)) mask_fifo
	(
		.in(put_mask),
		.out(mask_fifo_out),
		.in_ready(mask_fifo_ready),
		.in_valid(put),
		.out_ready(dac_ready && (!mask_fifo_out || fb_fifo_valid)),
		.out_valid(mask_fifo_valid),
		.*
	);

	// 2x para evitar potencial overflow cuando fb_read=1 pero mask_fifo está llena
	gfx_fifo #(.WIDTH($bits(mem_word)), .DEPTH(2 * `GFX_SCANOUT_FIFO_DEPTH)) fb_fifo
	(
		.in(fb_readdata),
		.out(fb_fifo_out),
		.in_ready(), // readdatavalid no soporta backpressure
		.in_valid(fb_readdatavalid),
		.out_ready(dac_ready && mask_fifo_valid && mask_fifo_out),
		.out_valid(fb_fifo_valid),
		.*
	);

	gfx_scanout_dac dac
	(
		.in_ready(dac_ready),
		.in_valid(mask_fifo_valid && (!mask_fifo_out || fb_fifo_valid)),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			put <= 0;
			fb_read <= 0;
			wait_vsync <= 0;
			commit_addr <= 0;
			mask_in_addr <= 0;
		end else begin
			mask_in_addr <= mask_in_addr + 1;

			if (flush || wait_vsync)
				mask_in_addr <= commit_addr;

			if (commit) begin
				wait_vsync <= start_vsync;
				commit_addr <= start_vsync ? 0 : mask_out_addr;
			end

			if (fb_ready)
				fb_read <= mask_fifo_ready && pop && !next_vsync && effective_mask;

			if (mask_fifo_ready)
				put <= fb_ready && pop && !next_vsync;

			if (vsync)
				wait_vsync <= 0;
		end

	always_ff @(posedge clk) begin
		mask_hold_addr <= mask_out_addr;

		if (fb_ready)
			fb_address <= mask_out_addr;

		if (mask_fifo_ready)
			put_mask <= effective_mask;
	end

endmodule
