`include "gfx/gfx_defs.sv"

module gfx_sp
(
	input  logic     clk,
	                 rst_n,

	input  logic     batch_waitrequest,
	                 batch_readdatavalid,
	input  vram_word batch_readdata,
	output vram_addr batch_address,
	output logic     batch_read,

	input  logic     fetch_waitrequest,
	                 fetch_readdatavalid,
	input  vram_word fetch_readdata,
	output vram_addr fetch_address,
	output logic     fetch_read,

	input  logic     program_start,
	input  cmd_word  program_header_base,
	                 program_header_size,

	input  logic     send_ready,
	output logic     send_valid,
	output lane_word send_data,
	output lane_mask send_mask
);

	logic batch_start, clear_lanes, insn_valid, running;
	cmd_word batch_length;
	insn_word insn;
	vram_insn_addr batch_base;

	gfx_sp_fetch fetch
	(
		.ready(insn_ready),
		.valid(insn_valid),
		.*
	);

	logic deco_valid, insn_ready;
	insn_deco deco;

	gfx_sp_decode decode
	(
		.*
	);

	logic recv_valid;
	lane_word recv_data;
	lane_mask recv_mask;

	gfx_sp_batch batch
	(
		.out_data(recv_data),
		.out_mask(recv_mask),
		.out_ready(recv_ready),
		.out_valid(recv_valid),
		.*
	);

	logic shuffler_wb_valid;
	wb_op shuffler_wb;

	gfx_sp_shuffler shuffler
	(
		.wb(shuffler_wb),
		.deco(),
		.in_ready(),
		.in_valid(0),
		.wb_ready(shuffler_wb_ready),
		.wb_valid(shuffler_wb_valid),
		.*
	);

	logic combiner_wb_valid;
	wb_op combiner_wb;

	gfx_sp_combiner combiner
	(
		.wb(combiner_wb),
		.deco(),
		.in_ready(),
		.in_valid(0),
		.wb_ready(combiner_wb_ready),
		.wb_valid(combiner_wb_valid),
		.*
	);

	logic recv_ready, stream_wb_valid;
	wb_op stream_wb;

	gfx_sp_stream stream
	(
		.wb(stream_wb),
		.deco(),
		.in_ready(),
		.in_valid(0),
		.wb_ready(stream_wb_ready),
		.wb_valid(stream_wb_valid),
		.*
	);

	mat4 wr_data;
	logic combiner_wb_ready, shuffler_wb_ready, stream_wb_ready, wr;
	vreg_num wr_reg;

	gfx_sp_writeback writeback
	(
		.*
	);

	mat4 a, b;

	gfx_sp_regs regs
	(
		.rd_a_reg(),
		.rd_b_reg(),
		.rd_a_data(a),
		.rd_b_data(b),
		.*
	);

	logic batch_end, deco_ready;
	assign deco_ready = 1;

endmodule
