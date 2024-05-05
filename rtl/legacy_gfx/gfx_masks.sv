`include "gfx/gfx_defs.sv"

module gfx_masks
(
	input  logic        clk,
	                    rst_n,

	input  logic        swap_buffers,
	input  cmd_word     fb_base_a,
	                    fb_base_b,

	input  linear_coord scan_mask_addr,
	output logic        scan_mask,

	input  logic        frag_mask_write,
	                    frag_mask_set,
	input  linear_coord frag_mask_read_addr,
	                    frag_mask_write_addr,
	output logic        frag_mask,

	output vram_addr    frag_base,
	                    scan_base
);

	logic mask_a, mask_b, frag_write_hold, frag_set_hold;
	linear_coord scan_addr_hold, frag_write_addr_hold, frag_read_addr_hold;

	gfx_mask_sram sram_a
	(
		.set(frag_set_hold),
		.mask(mask_a),
		.write(swap_buffers && frag_write_hold),
		.read_addr(swap_buffers ? frag_read_addr_hold : scan_addr_hold),
		.write_addr(frag_write_addr_hold),
		.*
	);

	gfx_mask_sram sram_b
	(
		.set(frag_set_hold),
		.mask(mask_b),
		.write(!swap_buffers && frag_write_hold),
		.read_addr(swap_buffers ? scan_addr_hold : frag_read_addr_hold),
		.write_addr(frag_write_addr_hold),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			frag_base <= 0;
			scan_base <= 0;
		end else begin
			frag_base <= swap_buffers ? fb_base_a[$bits(vram_addr):1] : fb_base_b[$bits(vram_addr):1];
			scan_base <= swap_buffers ? fb_base_b[$bits(vram_addr):1] : fb_base_a[$bits(vram_addr):1];
		end

	always_ff @(posedge clk) begin
		scan_mask <= swap_buffers ? mask_b : mask_a;
		scan_addr_hold <= scan_mask_addr;

		frag_mask <= swap_buffers ? mask_a : mask_b;
		frag_set_hold <= frag_mask_set;
		frag_write_hold <= frag_mask_write;
		frag_read_addr_hold <= frag_mask_read_addr;
		frag_write_addr_hold <= frag_mask_write_addr;
	end

endmodule
