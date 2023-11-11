`include "gfx/gfx_defs.sv"

module gfx_raster_coarse
(
	input  logic      clk,
	                  rst_n,

	input  raster_xy  pos_ref,
	input  coarse_dim span_x,
	                  span_y,
	input  fixed_tri  edge_refs,
	                  coarse_x_offsets,
	                  coarse_y_offsets,
	                  coarse_test_offsets,

	input  logic      in_valid,
	output logic      in_ready,

	input  logic      out_ready,
	output logic      out_valid,

	output raster_xy  pos,
	output fixed_tri  corners
);

	fixed reference_x;
	logic end_x, end_y, running, send, send_valid, skid_ready, stall;
	raster_xy next_pos;
	fixed_tri edge_fns, edge_tests, edge_vert, edge_vert_next;
	coarse_dim stride_x, stride_y, width;
	logic[2:0] edge_signs;

	struct packed
	{
		raster_xy pos;
		fixed_tri corners;
	} out, skid_out;

	assign pos = skid_out.pos;
	assign corners = skid_out.corners;

	assign end_x = stride_x == 0;
	assign end_y = stride_y == 0;

	assign send = &edge_signs && send_valid;
	assign in_ready = skid_ready && !running;

	gfx_skid_buf #(.WIDTH($bits(out))) skid_buf
	(
		.in(out),
		.out(skid_out),
		.*
	);

	gfx_skid_flow skid_flow
	(
		.in_ready(skid_ready),
		.in_valid(send),
		.*
	);

	always_comb
		for (integer i = 0; i < 3; ++i) begin
			edge_tests[i] = edge_fns[i] + coarse_test_offsets[i];
			edge_vert_next[i] = edge_vert[i] + coarse_y_offsets[i];
		end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			running <= 0;
			send_valid <= 0;
		end else if (!stall) begin
			if (running)
				running <= !end_x || !end_y;
			else
				running <= in_ready && in_valid;

			send_valid <= running;
		end

	always_ff @(posedge clk)
		if (!stall) begin
			out.pos <= next_pos;
			out.corners <= edge_fns;

			stride_x <= stride_x - 1;
			next_pos.x <= next_pos.x + (1 << (`FIXED_FRAC + `GFX_RASTER_BITS));

			if (end_x) begin
				next_pos.x <= reference_x;
				next_pos.y <= next_pos.y + (1 << (`FIXED_FRAC + `GFX_RASTER_BITS));

				stride_x <= width;
				stride_y <= stride_y - 1;
			end

			if (in_ready && in_valid) begin
				next_pos <= pos_ref;
				reference_x <= pos_ref.x;

				width <= span_x;
				stride_x <= span_x;
				stride_y <= span_y;
			end

			for (integer i = 0; i < 3; ++i) begin
				edge_fns[i] <= edge_fns[i] + coarse_x_offsets[i];
				if (end_x) begin
					edge_fns[i] <= edge_vert_next[i];
					edge_vert[i] <= edge_vert_next[i];
				end

				if (in_ready && in_valid) begin
					edge_fns[i] <= edge_refs[i];
					edge_vert[i] <= edge_refs[i];
				end

				edge_signs[i] <= !edge_tests[i][$bits(fixed) - 1];
			end
		end

endmodule
