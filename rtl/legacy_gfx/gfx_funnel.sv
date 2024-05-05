`include "gfx/gfx_defs.sv"

module gfx_funnel
(
	input  logic         clk,
	                     rst_n,

	input  frag_xy_lanes fragments,
	input  bary_lanes    barys,
	input  fixed_tri     raster_ws,
	input  paint_lanes   in_valid,
	output logic         in_ready,

	input  logic         out_ready,
	output logic         out_valid,
	output frag_xy       frag,
	output fixed_tri     frag_bary,
	                     frag_ws
);

	logic skid_ready, stall, ready, valid;
	frag_xy next_frag, out_frag;
	fixed_tri next_bary, out_bary, out_ws, ws_hold;
	bary_lanes barys_hold;
	paint_lanes current, next;
	frag_xy_lanes fragments_hold;

	assign ready = !(|next);
	assign in_ready = skid_ready && ready;

	gfx_skid_buf #(.WIDTH($bits(frag))) skid_frag
	(
		.in(out_frag),
		.out(frag),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(frag_bary))) skid_bary
	(
		.in(out_bary),
		.out(frag_bary),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(frag_ws))) skid_ws
	(
		.in(out_ws),
		.out(frag_ws),
		.*
	);

	gfx_skid_flow skid_flow
	(
		.in_ready(skid_ready),
		.in_valid(valid),
		.*
	);

	always_comb begin
		next = 0;
		next_bary = {($bits(next_bary)){1'bx}};
		next_frag = {($bits(next_frag)){1'bx}};

		for (integer i = 0; i < `GFX_FINE_LANES; ++i)
			if (current[i]) begin
				next = current;
				next[i] = 0;

				next_bary = barys_hold[i];
				next_frag = fragments_hold[i];
			end
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			valid <= 0;
			current <= 0;
		end else if (!stall) begin
			valid <= |current;
			current <= ready ? in_valid : next;
		end

	always_ff @(posedge clk)
		if (!stall) begin
			if (ready) begin
				ws_hold <= raster_ws;
				barys_hold <= barys;
				fragments_hold <= fragments;
			end

			out_ws <= ws_hold;
			out_bary <= next_bary;
			out_frag <= next_frag;
		end

endmodule
