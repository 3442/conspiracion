`include "gfx/gfx_defs.sv"

module gfx_sp_writeback
(
	input  logic    clk,
	                rst_n,

	input  wb_op    stream_wb,
	input  logic    stream_wb_valid,
	output logic    stream_wb_ready,

	input  wb_op    combiner_wb,
	input  logic    combiner_wb_valid,
	output logic    combiner_wb_ready,

	input  wb_op    shuffler_wb,
	input  logic    shuffler_wb_valid,
	output logic    shuffler_wb_ready,

	output logic    wr,
	output vreg_num wr_reg,
	output mat4     wr_data
);

	wb_op wb_in, wb_out;

	assign wr_reg = wb_out.dst;
	assign wr_data = wb_out.data;

	gfx_pipeline_flow #(.STAGES(`GFX_SP_WB_STAGES)) flow
	(
		.stall(),
		.in_ready(),
		.in_valid(stream_wb_valid || combiner_wb_valid || shuffler_wb_valid),
		.out_ready(1),
		.out_valid(wr),
		.*
	);

	gfx_pipes #(.WIDTH($bits(wb_out)), .DEPTH(`GFX_SP_WB_STAGES)) pipes
	(
		.in(wb_in),
		.out(wb_out),
		.stall(0),
		.*
	);

	always_comb begin
		stream_wb_ready = 0;
		combiner_wb_ready = 0;
		shuffler_wb_ready = 0;

		if (stream_wb_valid) begin
			wb_in = stream_wb;
			stream_wb_ready = 1;
		end else if (shuffler_wb_valid) begin
			wb_in = shuffler_wb;
			shuffler_wb_ready = 1;
		end else begin
			wb_in = combiner_wb;
			combiner_wb_ready = 1;
		end
	end

endmodule
