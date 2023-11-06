`include "gfx/gfx_defs.sv"

module gfx_fixed_fma_dot
(
	input  logic clk,

	input  fixed a0,
	             b0,
	             a1,
	             b1,
	             c,
	input  logic stall,

	output fixed q
);

	fixed q0, a1_hold[`FIXED_FMA_STAGES], b1_hold[`FIXED_FMA_STAGES];

	gfx_fixed_fma fma0
	(
		.a(a0),
		.b(b0),
		.q(q0),
		.*
	);

	gfx_fixed_fma fma1
	(
		.a(a1_hold[`FIXED_FMA_STAGES - 1]),
		.b(b1_hold[`FIXED_FMA_STAGES - 1]),
		.c(q0),
		.*
	);

	integer i;

	always_ff @(posedge clk)
		if (!stall) begin
			a1_hold[0] <= a1;
			b1_hold[0] <= b1;

			for (i = 1; i < `FIXED_FMA_STAGES; ++i) begin
				a1_hold[i] <= a1_hold[i - 1];
				b1_hold[i] <= b1_hold[i - 1];
			end
		end

endmodule
