module gfx_fpint
import gfx::*;
(
	input  logic             clk,
	                         rst_n,

	input  fpint_op          op,
	input  logic             abort,
	                         in_valid,

	       gfx_regfile_io.ab read_data,

	       gfx_wb.tx         wb
);

	logic stage_valid[FPINT_STAGES];
	fpint_op stage_op[FPINT_STAGES];

	assign stage_op[0] = op;
	assign stage_valid[0] = in_valid;

	genvar lane;
	generate
		for (lane = 0; lane < SHADER_LANES; ++lane) begin: lanes
			gfx_fpint_lane unit
			(
				.clk(clk),
				.a(read_data.a[lane]),
				.b(read_data.b[lane]),
				.q(wb.lanes[lane]),
				.mul_float_0(stage_op[0].setup_mul_float),
				.unit_b_0(stage_op[0].setup_unit_b),
				.put_hi_2(stage_op[2].mnorm_put_hi),
				.put_lo_2(stage_op[2].mnorm_put_lo),
				.put_mul_2(stage_op[2].mnorm_put_mul),
				.zero_b_2(stage_op[2].mnorm_zero_b),
				.zero_flags_2(stage_op[2].mnorm_zero_flags),
				.abs_3(stage_op[3].minmax_abs),
				.swap_3(stage_op[3].minmax_swap),
				.zero_min_3(stage_op[3].minmax_zero_min),
				.copy_flags_3(stage_op[3].minmax_copy_flags),
				.int_signed_5(stage_op[5].shiftr_int_signed),
				.copy_flags_6(stage_op[6].addsub_copy_flags),
				.int_operand_6(stage_op[6].addsub_int_operand),
				.force_nop_7(stage_op[7].clz_force_nop),
				.copy_flags_11(stage_op[11].shiftl_copy_flags),
				.copy_flags_12(stage_op[12].round_copy_flags),
				.enable_12(stage_op[12].round_enable),
				.enable_14(stage_op[14].encode_enable)
			);
		end
	endgenerate

	always_ff @(posedge clk)
		for (int i = 1; i < FPINT_STAGES; ++i)
			stage_op[i] <= stage_op[i - 1];

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			for (int i = 1; i < FPINT_STAGES; ++i)
				stage_valid[i] <= 0;

			wb.valid <= 0;
		end else begin
			for (int i = 1; i < FPINT_STAGES; ++i)
				stage_valid[i] <= stage_valid[i - 1];

			// Se levanta 1 ciclo luego que in_valid
			if (abort)
				stage_valid[2] <= 0;

			wb.valid <= stage_valid[FPINT_STAGES - 1];
		end

endmodule
