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

	logic batch_start, clear_lanes, running;
	cmd_word batch_length;
	insn_word insn;
	vram_insn_addr batch_base;

	gfx_sp_fetch fetch
	(
		.ready(1),
		.valid(),
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

	logic batch_end;

endmodule
