`include "gfx/gfx_defs.sv"

module gfx_mask_sram
(
	input  logic        clk,

	input  logic        set,
	                    write,
	input  linear_coord write_addr,
	                    read_addr,
	output logic        mask
);

	logic mem[`GFX_LINEAR_RES];
	logic mask_hold, write_hold, set_hold;
	linear_coord read_addr_hold, write_addr_hold;

	always_ff @(posedge clk) begin
		mask <= mask_hold;
		mask_hold <= mem[read_addr_hold];
		read_addr_hold <= read_addr;

		set_hold <= set;
		write_hold <= write;
		write_addr_hold <= write_addr;

		if (write_hold)
			mem[write_addr_hold] <= set_hold;
	end

endmodule
