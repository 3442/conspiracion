`include "gfx/gfx_defs.sv"

module gfx_setup_bounds
(
	input  logic      clk,

	input  raster_xy  vertex_a,
	                  vertex_b,
	                  vertex_c,
	input  logic      stall,

	output raster_xy  reference,
	output coarse_dim span_x,
	                  span_y
);

	logic x_a_lt_b, x_a_lt_c, x_b_lt_c, y_a_lt_b, y_a_lt_c, y_b_lt_c;
	raster_xy min, max, hold_a, hold_b, hold_c;
	coarse_dim ref_x, ref_y;
	raster_xy_prec min_prec, max_prec, ref_prec;

	assign min_prec = min;
	assign max_prec = max;
	assign reference = ref_prec;

	assign ref_prec.x.sub = 0;
	assign ref_prec.x.fine = 0;
	assign ref_prec.x.padding = {`GFX_RASTER_PAD_BITS{ref_x[$bits(ref_x) - 1]}};
	assign {ref_prec.x.sign, ref_prec.x.coarse} = ref_x;

	assign ref_prec.y.sub = 0;
	assign ref_prec.y.fine = 0;
	assign ref_prec.y.padding = {`GFX_RASTER_PAD_BITS{ref_y[$bits(ref_y) - 1]}};
	assign {ref_prec.y.sign, ref_prec.y.coarse} = ref_y;

	always_ff @(posedge clk)
		if (!stall) begin
			hold_a <= vertex_a;
			hold_b <= vertex_b;
			hold_c <= vertex_c;

			x_a_lt_b <= vertex_a.x < vertex_b.x;
			x_a_lt_c <= vertex_a.x < vertex_c.x;
			x_b_lt_c <= vertex_b.x < vertex_c.x;

			y_a_lt_b <= vertex_a.y < vertex_b.y;
			y_a_lt_c <= vertex_a.y < vertex_c.y;
			y_b_lt_c <= vertex_b.y < vertex_c.y;

			if (x_a_lt_b) begin
				min.x <= x_a_lt_c ? hold_a.x : hold_c.x;
				max.x <= x_b_lt_c ? hold_c.x : hold_b.x;
			end else begin
				min.x <= x_b_lt_c ? hold_b.x : hold_c.x;
				max.x <= x_a_lt_c ? hold_c.x : hold_a.x;
			end

			if (y_a_lt_b) begin
				min.y <= y_a_lt_c ? hold_a.y : hold_c.y;
				max.y <= y_b_lt_c ? hold_c.y : hold_b.y;
			end else begin
				min.y <= y_b_lt_c ? hold_b.y : hold_c.y;
				max.y <= y_a_lt_c ? hold_c.y : hold_a.y;
			end

			ref_x <= {min_prec.x.sign, min_prec.x.coarse};
			ref_y <= {min_prec.y.sign, min_prec.y.coarse};

			span_x <= {max_prec.x.sign, max_prec.x.coarse} - {min_prec.x.sign, min_prec.x.coarse};
			span_y <= {max_prec.y.sign, max_prec.y.coarse} - {min_prec.y.sign, min_prec.y.coarse};
		end

endmodule
