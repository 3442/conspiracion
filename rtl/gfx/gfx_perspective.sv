`include "gfx/gfx_defs.sv"

module gfx_perspective
(
	input  logic clk,

	input  attr4 clip_attr,
	input  logic stall,
	             in_start,
	             out_start,

	output attr4 ndc_attr,
	output fp    w_inv
);

	fp selected_w_inv, next_w_inv, vertex_w_inv, w_inv_pipes[`FP_MUL_STAGES];
	vec4 in_pipes[`FP_INV_STAGES], div_q;

	assign w_inv = w_inv_pipes[`FP_MUL_STAGES - 1];
	assign selected_w_inv = in_start ? next_w_inv : vertex_w_inv;

	gfx_fp_inv inv
	(
		.a(clip_attr.w),
		.q(next_w_inv),
		.*
	);

	genvar i;
	generate
		for (i = 0; i < `FLOATS_PER_VEC; ++i) begin: divs
			gfx_fp_mul div
			(
				.a(in_pipes[`FP_INV_STAGES - 1][i]),
				.b(selected_w_inv),
				.q(div_q[i]),
				.*
			);
		end

		for (i = 1; i < `FP_INV_STAGES; ++i) begin: in
			always_ff @(posedge clk)
				if (!stall)
					in_pipes[i] <= in_pipes[i - 1];
		end

		for (i = 1; i < `FP_MUL_STAGES; ++i) begin: out
			always_ff @(posedge clk)
				if (!stall)
					w_inv_pipes[i] <= w_inv_pipes[i - 1];
		end
	endgenerate

	always_comb begin
		ndc_attr = div_q;
		if (out_start)
			ndc_attr.w = `FP_UNIT;
	end

	always_ff @(posedge clk)
		if (!stall) begin
			if (in_start)
				vertex_w_inv <= next_w_inv;

			in_pipes[0] <= clip_attr;
			w_inv_pipes[0] <= selected_w_inv;
		end

endmodule
