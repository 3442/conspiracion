`include "gfx/gfx_defs.sv"

module fp_inv
(
	input  logic clk,

	input  fp    a,
	input  logic stall,

	output fp    q
);

`ifndef VERILATOR
	ip_fp_inv ip_inv
	(
		.en(!stall),
		.areset(0),
		.*
	);
`else
	fp pipeline[`FP_INV_STAGES - 1];

	integer i;

	always_ff @(posedge clk)
		if (!stall) begin
			pipeline[0] <= a;

			for (i = 1; i < `FP_INV_STAGES - 1; ++i)
				pipeline[i] <= pipeline[i - 1];

			q <= $c("taller::fp_inv(", pipeline[`FP_INV_STAGES - 2], ")");
		end
`endif

endmodule
