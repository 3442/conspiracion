module vdc_io
import vdc_pkg::*;
(
	input  logic      clk,
	                  rst_n,

	input  logic      frame_start,
	input  ptr        front_base,
	input  geom_dim   lines,
	                  stride,
	                  line_len,
	output logic      frame_done,

	       if_axib.m  stream,

	       vdc_dac.tx dac
);

	localparam int BURST_BITS = 4;

	enum int unsigned
	{
		ORDER_B_RGB,
		ORDER_GB_RG,
		ORDER_RGB_R,
		ORDER_BUBBLE
	} word_order;

	ptr araddr, stride_jump, stride_save;
	logic bubble, burst_ar_last, first_pix, last_pix, next_bubble, word_r_last;
	geom_dim line_ar_count, line_r_count, word_r_count;
	pix_rgb24 dac_pix, next_pix;
	logic[3:0][7:0] in_cur, in_prev;
	logic[$bits(geom_dim) - BURST_BITS - 1:0] burst_ar_count, bursts_per_line;

	assign stream.arid = '0;
	assign stream.arlen = ($bits(stream.arlen))'((1 << BURST_BITS) - 1);
	assign stream.arsize = 3'b010; // 4 bytes/beat
	assign stream.araddr = {araddr, 2'b00};
	assign stream.arburst = 2'b01; // Incremental mode

	assign stream.rready = (~dac.valid | dac.ready) & ~bubble;

	assign stream.awid = 'x;
	assign stream.awlen = 'x;
	assign stream.awsize = 'x;
	assign stream.awaddr = 'x;
	assign stream.awburst = 'x;
	assign stream.awvalid = 0;

	assign stream.wdata = 'x;
	assign stream.wlast = 'x;
	assign stream.wstrb = 'x;
	assign stream.wvalid = 0;

	assign stream.bready = 0;

	assign dac.pix.b = rgb8to10(dac_pix.b);
	assign dac.pix.g = rgb8to10(dac_pix.g);
	assign dac.pix.r = rgb8to10(dac_pix.r);

	assign in_cur = stream.rdata;
	assign last_pix = bubble & word_r_last & (line_r_count == '0);
	assign stride_jump = stride_save + {{($bits(araddr) - $bits(stride)){1'b0}}, stride};
	assign word_r_last = word_r_count == '0;
	assign burst_ar_last = burst_ar_count == '0;
	assign bursts_per_line = line_len[$bits(line_len) - 1:BURST_BITS];

	always_comb begin
		unique case (word_order)
			ORDER_RGB_R: next_bubble = 1;
			default:     next_bubble = 0;
		endcase

		unique case (word_order)
			ORDER_BUBBLE: bubble = 1;
			default:      bubble = 0;
		endcase

		unique case (word_order)
			ORDER_B_RGB: begin
				next_pix.b = in_cur[0];
				next_pix.g = in_cur[1];
				next_pix.r = in_cur[2];
			end

			ORDER_GB_RG: begin
				next_pix.b = in_prev[3];
				next_pix.g = in_cur[0];
				next_pix.r = in_cur[1];
			end

			ORDER_RGB_R: begin
				next_pix.b = in_prev[2];
				next_pix.g = in_prev[3];
				next_pix.r = in_cur[0];
			end

			ORDER_BUBBLE: begin
				next_pix.b = in_prev[1];
				next_pix.g = in_prev[2];
				next_pix.r = in_prev[3];
			end
		endcase
	end

	always_ff @(posedge clk) begin
		if (stream.arvalid & stream.arready) begin
			araddr <= araddr + ($bits(araddr))'(1 << BURST_BITS);

			burst_ar_count <= burst_ar_count - 1;
			if (burst_ar_last) begin
				araddr <= stride_jump;
				stride_save <= stride_jump;

				burst_ar_count <= bursts_per_line;
				line_ar_count <= line_ar_count - 1;
			end
		end

		if (stream.rvalid & stream.rready)
			in_prev <= in_cur;

		if (~dac.valid | dac.ready) begin
			dac_pix <= next_pix;
			dac.last <= last_pix;
			dac.first <= first_pix;
		end

		if (dac.valid & dac.ready) begin
			first_pix <= 0;

			unique case (word_order)
				ORDER_B_RGB:  word_order <= ORDER_GB_RG;
				ORDER_GB_RG:  word_order <= ORDER_RGB_R;
				ORDER_RGB_R:  word_order <= ORDER_BUBBLE;
				ORDER_BUBBLE: word_order <= ORDER_B_RGB;
			endcase

			if (~next_bubble) begin
				word_r_count <= word_r_count - 1;
				if (word_r_last) begin
					line_r_count <= line_r_count - 1;
					word_r_count <= line_len;
				end
			end
		end

		if (frame_start) begin
			araddr <= front_base;
			stride_save <= front_base;
			line_ar_count <= lines;
			burst_ar_count <= bursts_per_line;

			first_pix <= 1;
			word_order <= ORDER_B_RGB;

			line_r_count <= lines;
			word_r_count <= line_len;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			dac.valid <= 0;
			frame_done <= 0;
			stream.arvalid <= 0;
		end else begin
			dac.valid <= (dac.valid & ~dac.ready) | bubble | stream.rvalid;

			unique case (1'b1)
				frame_start:
					stream.arvalid <= 1;

				stream.arvalid & stream.arready & burst_ar_last & (line_ar_count == '0):
					stream.arvalid <= 0;

				default: ;
			endcase

			frame_done <= dac.valid & dac.ready & last_pix;
		end

endmodule
