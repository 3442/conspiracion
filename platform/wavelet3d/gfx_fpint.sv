module gfx_fpint
(
	input  logic     clk,
	                 rst_n,

	input  gfx::word a[gfx::SHADER_LANES],
	                 b[gfx::SHADER_LANES],
	input logic      in_valid,
	                 setup_mul_float,
	                 setup_unit_b,
	                 mnorm_put_hi,
	                 mnorm_put_lo,
	                 mnorm_put_mul,
	                 mnorm_zero_b,
	                 mnorm_zero_flags,
	                 minmax_copy_flags,
	                 shiftr_int_signed,
	                 addsub_copy_flags,
	                 addsub_int_operand,
	                 clz_force_nop,
	                 shiftl_copy_flags,
	                 round_copy_flags,
	                 round_enable,
	                 encode_enable,

	output logic     out_valid,
	output gfx::word q[gfx::SHADER_LANES]
);

	import gfx::*;

	logic stage_valid[FPINT_STAGES];
	fpint_op op, stage_op[FPINT_STAGES];

	assign stage_op[0] = op;
	assign stage_valid[0] = in_valid;

	assign op.setup_mul_float = setup_mul_float;
	assign op.setup_unit_b = setup_unit_b;
	assign op.mnorm_put_hi = mnorm_put_hi;
	assign op.mnorm_put_lo = mnorm_put_lo;
	assign op.mnorm_put_mul = mnorm_put_mul;
	assign op.mnorm_zero_b = mnorm_zero_b;
	assign op.mnorm_zero_flags = mnorm_zero_flags;
	assign op.minmax_copy_flags = minmax_copy_flags;
	assign op.shiftr_int_signed = shiftr_int_signed;
	assign op.addsub_copy_flags = addsub_copy_flags;
	assign op.addsub_int_operand = addsub_int_operand;
	assign op.clz_force_nop = clz_force_nop;
	assign op.shiftl_copy_flags = shiftl_copy_flags;
	assign op.round_copy_flags = round_copy_flags;
	assign op.round_enable = round_enable;
	assign op.encode_enable = encode_enable;

	genvar lane;
	generate
		for (lane = 0; lane < SHADER_LANES; ++lane) begin: lanes
			gfx_fpint_lane unit
			(
				.clk(clk),
				.a(a[lane]),
				.b(b[lane]),
				.q(q[lane]),
				.mul_float_0(stage_op[0].setup_mul_float),
				.unit_b_0(stage_op[0].setup_unit_b),
				.put_hi_2(stage_op[2].mnorm_put_hi),
				.put_lo_2(stage_op[2].mnorm_put_lo),
				.put_mul_2(stage_op[2].mnorm_put_mul),
				.zero_b_2(stage_op[2].mnorm_zero_b),
				.zero_flags_2(stage_op[2].mnorm_zero_flags),
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

	always_ff @(posedge clk or negedge rst_n) begin
		for (int i = 1; i < FPINT_STAGES; ++i)
			stage_valid[i] <= !rst_n ? 0 : stage_valid[i - 1];

		out_valid <= !rst_n ? 0 : stage_valid[FPINT_STAGES - 1];
	end

endmodule
