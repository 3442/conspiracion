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
	                 program_header_size
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

	gfx_sp_batch batch
	(
		.out_data(),
		.out_mask(),
		.out_ready(1),
		.out_valid(),
		.*
	);

	gfx_sp_shuffler shuffler
	(
		.a(),
		.b(),
		.wb(),
		.deco(),
		.in_ready(),
		.in_valid(0),
		.wb_ready(1),
		.wb_valid(),
		.*
	);

	gfx_sp_combiner combiner
	(
		.a(),
		.b(),
		.wb(),
		.deco(),
		.in_ready(),
		.in_valid(0),
		.wb_ready(1),
		.wb_valid(),
		.*
	);

	logic batch_end, deco_ready;
	assign deco_ready = 1;

endmodule
