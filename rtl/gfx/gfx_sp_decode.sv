`include "gfx/gfx_defs.sv"
`include "gfx/gfx_sp_isa.sv"

module gfx_sp_decode
(
	input  logic     clk,
	                 rst_n,

	input  logic     clear_lanes,
	input  insn_word insn,
	input  logic     insn_valid,
	output logic     insn_ready,

	output insn_deco deco,
	input  logic     deco_ready,
	output logic     deco_valid
);

	logic stall;
	insn_deco deco_in, deco_out;

	gfx_pipeline_flow #(.STAGES(1)) flow
	(
		.in_ready(insn_ready),
		.in_valid(insn_valid),
		.out_ready(deco_ready),
		.out_valid(deco_valid),
		.*
	);

	gfx_pipes #(.WIDTH($bits(deco)), .DEPTH(1)) pipe
	(
		.in(deco_in),
		.out(deco_out),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(deco))) skid
	(
		.in(deco_out),
		.out(deco),
		.*
	);

	always_comb begin
		deco_in.writeback = 0;
		deco_in.read_src_a = 0;
		deco_in.read_src_b = 0;

		deco_in.ex.stream = 0;
		deco_in.ex.combiner = 0;
		deco_in.ex.shuffler = 0;

		deco_in.shuffler.is_swizzle = 1'bx;
		deco_in.shuffler.is_broadcast = 1'bx;

		unique casez (insn)
			`GFX_INSN_OP_SELECT: begin
				deco_in.writeback = 1;
				deco_in.read_src_a = 1;
				deco_in.read_src_b = 1;

				deco_in.ex.shuffler = 1;
				deco_in.shuffler.is_swizzle = 0;
				deco_in.shuffler.is_broadcast = 0;
			end

			`GFX_INSN_OP_SWIZZL: begin
				deco_in.writeback = 1;
				deco_in.read_src_a = 1;

				deco_in.ex.shuffler = 1;
				deco_in.shuffler.is_swizzle = 1;
			end

			`GFX_INSN_OP_BROADC: begin
				deco_in.writeback = 1;

				deco_in.ex.shuffler = 1;
				deco_in.shuffler.is_swizzle = 0;
				deco_in.shuffler.is_broadcast = 1;
			end

			`GFX_INSN_OP_MATVEC: begin
				deco_in.writeback = 1;
				deco_in.read_src_a = 1;
				deco_in.read_src_b = 1;
				deco_in.ex.combiner = 1;
			end

			`GFX_INSN_OP_SEND: begin
				deco_in.read_src_a = 1;
				deco_in.ex.stream = 1;
			end

			`GFX_INSN_OP_RECV: begin
				deco_in.writeback = 1;
				deco_in.ex.stream = 1;
			end

			default:
				// Esto es jugar con fuego, pero lo vale con tal de que cierre el timing
				deco_in = {($bits(deco_in)){1'bx}};
		endcase

		deco_in.dst = insn `GFX_INSN_DST;
		deco_in.src_a = insn `GFX_INSN_SRC_A;
		deco_in.src_b = insn `GFX_INSN_SRC_B;
		deco_in.clear_lanes = clear_lanes;

		deco_in.shuffler.imm = insn `GFX_INSN_BROADC_IMM;
		deco_in.shuffler.select_mask = insn `GFX_INSN_SELECT_MASK;
		deco_in.shuffler.swizzle_op = insn `GFX_INSN_SWIZZL_LANES;
	end

endmodule
