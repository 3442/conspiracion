`include "gfx/gfx_defs.sv"

module gfx_fp_mul
(
	input  logic clk,

	input  fp    a,
	             b,
	input  logic stall,

	output fp    q
);

`ifndef VERILATOR
	ip_fp_mul ip_mul
	(
		.en(!stall),
		.areset(0),
		.*
	);
`else
	fp a_pipeline[`FP_MUL_STAGES - 1], b_pipeline[`FP_MUL_STAGES - 1];

	integer i;

	always_ff @(posedge clk)
		if (!stall) begin
			a_pipeline[0] <= a;
			b_pipeline[0] <= b;

			for (i = 1; i < `FP_MUL_STAGES - 1; ++i) begin
				a_pipeline[i] <= a_pipeline[i - 1];
				b_pipeline[i] <= b_pipeline[i - 1];
			end

			q <= $c("taller::fp_mul(", a_pipeline[`FP_MUL_STAGES - 2], ", ", b_pipeline[`FP_MUL_STAGES - 2], ")");
		end
`endif

endmodule
