`include "gfx/gfx_defs.sv"

module gfx_scanout
(
	input  logic        clk,
	                    rst_n,

	input  logic        enable_clear,
	input  rgb24        clear_color,

	input  logic        mask,
	output linear_coord mask_addr,

	input  logic        fb_waitrequest,
	                    fb_readdatavalid,
	input  logic[15:0]  fb_readdata,
	output logic        fb_read,
	output half_coord   fb_address,

	input  logic        scan_ready,
	output logic        scan_valid,
	                    scan_endofpacket,
	                    scan_startofpacket,
	output rgb30        scan_data,

	output logic        vsync
);

	logic[`GFX_SCAN_STAGES:0] fb_ready, fb_valid, src_ready, src_valid, src_pipes;
	logic[`GFX_SCAN_STAGES - 1:0] fb_stalls, src_stalls;
	logic[`GFX_MASK_STAGES - 1:0] request_valid;
	logic[$clog2(`GFX_SCAN_STAGES) - 1:0] queued;

	logic effective_mask, foreground, foreground_valid, partial, put_fb_valid, put_src_valid,
	      queued_dec, queued_inc, read_half, read_valid, request_flush;

	rgb24 fb_pipes[`GFX_SCAN_STAGES + 1], scan_pixel;
	half_coord commit_pos, next_pos, read_pos, request_pos[`GFX_MASK_STAGES - 1:0];
	logic[15:0] half;
	linear_coord scan_pos, last_pos;

	assign last_pos = `GFX_LINEAR_RES - 1;
	assign scan_data.r = {scan_pixel.r, {2{scan_pixel.r[0]}}};
	assign scan_data.g = {scan_pixel.g, {2{scan_pixel.g[0]}}};
	assign scan_data.b = {scan_pixel.b, {2{scan_pixel.b[0]}}};

	assign scan_pixel = foreground ? fb_pipes[`GFX_SCAN_STAGES] : clear_color;
	assign scan_valid = foreground_valid && (!foreground || fb_valid[`GFX_SCAN_STAGES]);
	assign scan_endofpacket = scan_pos == last_pos;
	assign scan_startofpacket = scan_pos == 0;

	assign foreground = src_pipes[`GFX_SCAN_STAGES];
	assign foreground_valid = src_valid[`GFX_SCAN_STAGES];

	// Soluciona Error-BLKANDNBLK en Verilator
	assign fb_valid[0] = put_fb_valid;
	assign src_valid[0] = put_src_valid;

	assign fb_ready[`GFX_SCAN_STAGES] = scan_ready && foreground_valid && foreground;
	assign src_ready[`GFX_SCAN_STAGES] = scan_ready && scan_valid;

	assign next_pos = request_flush ? commit_pos : read_pos;
	assign mask_addr = read_pos[$bits(read_pos) - 1:1];

	assign read_half = request_pos[`GFX_MASK_STAGES - 1][0];
	assign read_valid = request_valid[`GFX_MASK_STAGES - 1];
	assign request_flush = (fb_read && fb_waitrequest) || (src_valid[0] && !src_ready[0]) || queued == `GFX_SCAN_STAGES || vsync;

	assign queued_inc = !request_flush && read_valid && read_half && effective_mask;
	assign queued_dec = fb_ready[`GFX_SCAN_STAGES - 1] && fb_valid[`GFX_SCAN_STAGES - 1];
	assign effective_mask = mask || !enable_clear;

	genvar i;
	generate
		for (i = 0; i < `GFX_SCAN_STAGES; ++i) begin: stages
			pipeline_flow #(.STAGES(1)) fb_flow
			(
				.stall(fb_stalls[i]),
				.in_ready(fb_ready[i]),
				.in_valid(fb_valid[i]),
				.out_ready(fb_ready[i + 1]),
				.out_valid(fb_valid[i + 1]),
				.*
			);

			pipeline_flow #(.STAGES(1)) src_flow
			(
				.stall(src_stalls[i]),
				.in_ready(src_ready[i]),
				.in_valid(src_valid[i]),
				.out_ready(src_ready[i + 1]),
				.out_valid(src_valid[i + 1]),
				.*
			);

			always_ff @(posedge clk) begin
				if (!fb_stalls[i])
					fb_pipes[i + 1] <= fb_pipes[i];

				if (!src_stalls[i])
					src_pipes[i + 1] <= src_pipes[i];
			end
		end

		for (i = 1; i < `GFX_MASK_STAGES; ++i) begin: request
			always_ff @(posedge clk or negedge rst_n)
				request_valid[i] <= !rst_n ? 0 : (request_valid[i - 1] && !request_flush);

			always_ff @(posedge clk)
				request_pos[i] <= request_pos[i - 1];
		end
	endgenerate

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			vsync <= 0;
			queued <= 0;

			read_pos <= 0;
			scan_pos <= 0;
			commit_pos <= 0;

			fb_read <= 0;
			partial <= 0;

			put_fb_valid <= 0;
			put_src_valid <= 0;
			request_valid[0] <= 0;
		end else begin
			if (queued_inc && !queued_dec)
				queued <= queued + 1;
			else if (!queued_inc && queued_dec)
				queued <= queued - 1;

			if (scan_ready && scan_valid)
				scan_pos <= scan_endofpacket ? 0 : scan_pos + 1;

			partial <= partial ^ fb_readdatavalid;

			put_fb_valid <= partial && fb_readdatavalid;
			request_valid[0] <= !request_flush;

			read_pos <= next_pos + 1;
			if (next_pos == {last_pos, 1'b1})
				read_pos <= 0;

			if (!fb_waitrequest)
				fb_read <= 0;

			if (src_ready[0])
				put_src_valid <= 0;

			if (!request_flush) begin
				fb_read <= read_valid && effective_mask;
				put_src_valid <= read_valid && read_half;
	
				if (read_valid)
					commit_pos <= request_pos[`GFX_MASK_STAGES - 1];
			end

			vsync <= !vsync && !request_flush && read_valid && request_pos[`GFX_MASK_STAGES - 1] == {last_pos, 1'b1};
		end

	always_ff @(posedge clk) begin
		request_pos[0] <= read_pos;

		if (!request_flush) begin
			fb_address <= request_pos[`GFX_MASK_STAGES - 1];
			src_pipes[0] <= effective_mask;
		end

		if (fb_readdatavalid) begin
			if (partial)
				fb_pipes[0] <= {fb_readdata[7:0], half};
			else
				half <= fb_readdata;
		end
	end

endmodule
