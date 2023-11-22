`include "gfx/gfx_defs.sv"

module gfx_rop
(
	input  logic        clk,
	                    rst_n,

	input  vram_addr    frag_base,

	input  frag_paint   in,
	input  logic        in_valid,
	output logic        in_ready,

	input  logic        rop_waitrequest,
	output logic        rop_write,
	output vram_word    rop_writedata,
	output vram_addr    rop_address,

	output linear_coord mask_addr,
	output logic        mask_assert
);

	enum int unsigned
	{
		IDLE,
		WRITE_LO,
		WRITE_HI
	} state;

	logic hi;
	vram_word color_hi, color_lo;
	frag_paint hold;

	assign {color_hi, color_lo} = hold.color;

	assign mask_addr = hold.addr;
	assign rop_address = frag_base + {5'd0, hold.addr, hi};
	assign rop_writedata = hi ? color_hi : color_lo;

	always_comb begin
		hi = 1'bx;
		in_ready = 0;
		rop_write = 0;
		mask_assert = 0;

		unique case (state)
			IDLE: 
				in_ready = 1;

			WRITE_LO: begin
				hi = 0;
				rop_write = 1;
				mask_assert = 1;
			end

			WRITE_HI: begin
				hi = 1;
				in_ready = !rop_waitrequest;
				rop_write = 1;
			end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			state <= IDLE;
		else unique case (state)
			IDLE:
				if (in_valid)
					state <= WRITE_LO;

			WRITE_LO:
				if (!rop_waitrequest)
					state <= WRITE_HI;

			WRITE_HI:
				if (!rop_waitrequest)
					state <= in_valid ? WRITE_LO : IDLE;
		endcase

	always_ff @(posedge clk)
		if (in_ready)
			hold <= in;

endmodule
