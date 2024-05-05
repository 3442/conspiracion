`include "gfx/gfx_defs.sv"

module gfx_frag_shade
(
	input  logic            clk,

	input  fixed            b1,
	                        b2,
	input  color_lerp_lanes argb0,
	                        argb1_argb0,
	                        argb2_argb0,
	input  logic            stall,

	output rgb32            color
);

	struct packed
	{
		logic                                    sign;
		logic[$bits(fixed) - `FIXED_FRAC - 2:0]  out_of_range;
		color8                                   color;
		logic[`FIXED_FRAC - $bits(color8) - 1:0] sub;
	} lerped[`COLOR_CHANNELS];

	fixed channel_lerp[`COLOR_CHANNELS];
	color8[`COLOR_CHANNELS - 1:0] out;

	assign color = out;

	genvar i;
	generate
		for (i = 0; i < `COLOR_CHANNELS; ++i) begin: channels
			assign lerped[i] = channel_lerp[i];

			gfx_lerp lerp
			(
				.q(channel_lerp[i]),
				.q0(argb0[i]),
				.q1_q0(argb1_argb0[i]),
				.q2_q0(argb2_argb0[i]),
				.*
			);

			always_ff @(posedge clk)
				if (!stall) begin
					out[i] <= lerped[i].color;
					if (lerped[i].sign || |lerped[i].out_of_range)
						out[i] <= {($bits(color8)){!lerped[i].sign}};
				end
		end
	endgenerate

endmodule
