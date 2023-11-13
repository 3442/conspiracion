`include "gfx/gfx_defs.sv"

module gfx_frag_bary
(
	input  logic     clk,

	input  fixed_tri edges,
	                 ws,
	input  logic     stall,

	output fixed     b1,
	                 b2
);

	fixed area, b0_w0, b1_w1, b2_w2, b1_w1_b2_w2, hold_b0_w0, hold_b1_w1, hold_b2_w2;
	fixed_tri bs_ws, orthographic_bs;

	assign b0_w0 = bs_ws[0];
	assign b1_w1 = bs_ws[1];
	assign b2_w2 = bs_ws[2];

	assign orthographic_bs[0] = edges[`EDGE_P1_TO_P2];
	assign orthographic_bs[1] = edges[`EDGE_P2_TO_P0];
	assign orthographic_bs[2] = edges[`EDGE_P0_TO_P1];

	genvar i;
	generate
		for (i = 0; i < 3; ++i) begin: vertices
			gfx_fixed_div div_b_w
			(
				.z(orthographic_bs[i]),
				.d(ws[i]),
				.q(bs_ws[i]),
				.*
			);
		end
	endgenerate

	localparam AREA_STAGES = 2;

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(AREA_STAGES)) b1_w1_pipes
	(
		.in(b1_w1),
		.out(hold_b1_w1),
		.*
	);

	gfx_pipes #(.WIDTH($bits(fixed)), .DEPTH(AREA_STAGES)) b2_w2_pipes
	(
		.in(b2_w2),
		.out(hold_b2_w2),
		.*
	);

	gfx_fixed_div norm_b1
	(
		.z(hold_b1_w1),
		.d(area),
		.q(b1),
		.*
	);

	gfx_fixed_div norm_b2
	(
		.z(hold_b2_w2),
		.d(area),
		.q(b2),
		.*
	);

	always_ff @(posedge clk)
		if (!stall) begin
			area <= hold_b0_w0 + b1_w1_b2_w2;
			hold_b0_w0 <= b0_w0;
			b1_w1_b2_w2 <= b1_w1 + b2_w2;
		end

endmodule
