`include "gfx/gfx_defs.sv"

module gfx_sp_shuffler
(
	input  logic     clk,
	                 rst_n,

	input  mat4      a,
	                 b,
	input  insn_deco deco,
	input  logic     in_valid,
	output logic     in_ready,

	output wb_op     wb,
	input  logic     wb_ready,
	output logic     wb_valid
);

	mat4 select_out, swizzle_out;
	wb_op wb_out;
	logic stall, is_swizzle;
	vreg_num hold_dst;

	gfx_pipeline_flow #(.STAGES(2)) flow
	(
		.out_ready(wb_ready),
		.out_valid(wb_valid),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(wb))) skid
	(
		.in(wb_out),
		.out(wb),
		.*
	);

	genvar gen_i;
	generate
		for (gen_i = 0; gen_i < `GFX_SP_LANES; ++gen_i) begin: lanes
			gfx_sp_select select
			(
				.a(a[gen_i]),
				.b(b[gen_i]),
				.out(select_out[gen_i]),
				.deco(deco.shuffler),
				.*
			);

			gfx_sp_swizzle swizzle
			(
				.in(a[gen_i]),
				.out(swizzle_out[gen_i]),
				.deco(deco.shuffler),
				.*
			);
		end
	endgenerate

	always_ff @(posedge clk)
		if (!stall) begin
			hold_dst <= deco.dst;
			is_swizzle <= deco.shuffler.is_swizzle;

			wb_out.dst <= hold_dst;
			for (integer i = 0; i < `GFX_SP_LANES; ++i)
				wb_out.data[i] <= is_swizzle ? swizzle_out[i] : select_out[i];
		end

endmodule
