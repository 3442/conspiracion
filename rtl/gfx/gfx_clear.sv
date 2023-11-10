`include "gfx/gfx_defs.sv"

module gfx_clear
(
	input  logic        clk,
	                    rst_n,

	input  logic        start_clear,

	input  linear_coord rop_mask_addr,
	input  logic        rop_mask_assert,
	output logic        frag_wait,

	output logic        frag_mask_set,
	                    frag_mask_write,
	output linear_coord frag_mask_write_addr
);

	enum int unsigned
	{
		FRAG,
		CLEAR
	} state;

	logic end_clear;

	assign end_clear = frag_mask_write_addr == `GFX_LINEAR_RES - 1;

	always_comb
		unique case (state)
			FRAG:  frag_wait = start_clear;
			CLEAR: frag_wait = 1;
		endcase

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= FRAG;
			frag_mask_write <= 0;
		end else unique case (state)
			FRAG: begin
				frag_mask_write <= rop_mask_assert;

				if (start_clear) begin
					state <= CLEAR;
					frag_mask_write <= 1;
				end
			end

			CLEAR:
				if (end_clear) begin
					state <= FRAG;
					frag_mask_write <= 0;
				end
		endcase

	always_ff @(posedge clk)
		unique case (state)
			FRAG: begin
				frag_mask_set <= !start_clear;
				frag_mask_write_addr <= rop_mask_addr;

				if (start_clear)
					frag_mask_write_addr <= 0;
			end

			CLEAR:
				frag_mask_write_addr <= frag_mask_write_addr + 1;
		endcase

endmodule
