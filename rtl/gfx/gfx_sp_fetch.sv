`include "gfx/gfx_defs.sv"

module gfx_sp_fetch
(
	input  logic          clk,
	                      rst_n,

	input  logic          fetch_waitrequest,
	                      fetch_readdatavalid,
	input  vram_word      fetch_readdata,
	output vram_addr      fetch_address,
	output logic          fetch_read,

	input  logic          program_start,
	input  cmd_insn_ptr   program_header_base,
	input  cmd_word       program_header_size,
	output logic          running,

	input  logic          batch_end,
	output vram_insn_addr batch_base,
	output logic          batch_start,
	output cmd_word       batch_length,

	input  logic          ready,
	output logic          valid,
	output insn_word      insn,
	output logic          clear_lanes
);

	localparam ENTRY_SIZE = 4;

	logic break_loop, entry_end, fifo_down, fifo_up, fifo_put, header_continue,
	      insn_read, insn_readdatavalid, insn_waitrequest;

	cmd_word header_count;
	insn_word code_length, code_read_ptr, code_fetch_ptr, insn_readdata, entry_data[ENTRY_SIZE];
	vram_insn_addr code_base, insn_address, header_ptr;
	logic[$clog2(ENTRY_SIZE - 1):0] entry_fetch_count, entry_read_count;
	logic[$clog2(`GFX_FETCH_FIFO_DEPTH + 1) - 1:0] fifo_pending;

	enum int unsigned
	{
		IDLE,
		HEADER,
		LOOP,
		FLUSH
	} state;

	struct packed
	{
		insn_word insn;
		logic     clear_lanes;
	} fifo_in, fifo_out;

	assign insn = fifo_out.insn;
	assign clear_lanes = fifo_out.clear_lanes;

	assign entry_end = entry_read_count == ENTRY_SIZE - 1;
	assign header_continue = header_count != 0;
	assign break_loop = batch_end && (!insn_read || !insn_waitrequest);

	function vram_insn_addr base_from_word(insn_word in);
		base_from_word = in[$bits(in) - 1:$bits(in) - $bits(vram_insn_addr)];
	endfunction

	assign code_base = base_from_word(entry_data[0]);
	assign batch_base = base_from_word(entry_data[2]);
	assign code_length = entry_data[1];
	assign batch_length = entry_data[3];

	assign fifo_up = ready && valid;
	assign fifo_down = insn_read && !insn_waitrequest;

	gfx_sp_widener #(.WIDTH($bits(vram_insn_addr))) insn_bus
	(
		.wide_read(insn_read),
		.wide_address(insn_address),
		.wide_readdata(insn_readdata),
		.wide_waitrequest(insn_waitrequest),
		.wide_readdatavalid(insn_readdatavalid),
		.word_read(fetch_read),
		.word_address(fetch_address),
		.word_readdata(fetch_readdata),
		.word_waitrequest(fetch_waitrequest),
		.word_readdatavalid(fetch_readdatavalid),
		.*
	);

	gfx_fifo #(.WIDTH($bits(fifo_in)), .DEPTH(`GFX_FETCH_FIFO_DEPTH)) insn_fifo
	(
		.in(fifo_in),
		.out(fifo_out),
		.in_ready(),
		.in_valid(fifo_put),
		.out_ready(ready),
		.out_valid(valid),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= IDLE;
			running <= 0;
			fifo_put <= 0;
			insn_read <= 0;
			batch_start <= 0;
			fifo_pending <= 0;
		end else begin
			unique case (state)
				IDLE:
					if (program_start) begin
						state <= HEADER;
						running <= 1;
						insn_read <= 1;
					end

				HEADER: begin
					if (insn_read && !insn_waitrequest)
						insn_read <= entry_fetch_count == ENTRY_SIZE - 1;

					if (insn_readdatavalid && entry_end) begin
						state <= LOOP;
						insn_read <= 1;
						batch_start <= 1;
					end
				end

				LOOP: begin
					fifo_put <= 0;
					batch_start <= 0;

					if (!insn_read || !insn_waitrequest)
						insn_read <= fifo_pending < `GFX_FETCH_FIFO_DEPTH - 1;

					if (break_loop) begin
						state <= FLUSH;
						insn_read <= 0;
					end

					if (insn_readdatavalid)
						fifo_put <= 1;
				end

				FLUSH: begin
					fifo_put <= 0;

					if (fifo_pending == 0) begin
						state <= header_continue ? HEADER : IDLE;
						running <= header_continue;
						insn_read <= header_continue;
					end
				end
			endcase

			if (fifo_up && !fifo_down)
				fifo_pending <= fifo_pending - 1;
			else if (!fifo_up && fifo_down)
				fifo_pending <= fifo_pending + 1;
		end

	always_ff @(posedge clk)
		unique case (state)
			IDLE:
				if (program_start) begin
					header_ptr <= program_header_base.addr;
					header_count <= program_header_size;
					insn_address <= program_header_base.addr;

					entry_read_count <= 0;
					entry_fetch_count <= 0;
				end

			HEADER: begin
				code_read_ptr <= 0;
				code_fetch_ptr <= 0;

				if (!insn_waitrequest) begin
					insn_address <= insn_address + 1;
					entry_fetch_count <= entry_fetch_count + 1;
				end

				if (insn_read && !insn_waitrequest)
					header_ptr <= header_ptr + 1;

				if (insn_readdatavalid) begin
					entry_read_count <= entry_read_count + 1;

					for (integer i = 0; i < ENTRY_SIZE - 1; ++i)
						entry_data[i] <= entry_data[i + 1];

					entry_data[ENTRY_SIZE - 1] <= insn_readdata;

					if (entry_end)
						insn_address <= base_from_word(entry_data[1]);
				end
			end

			LOOP: begin
				if (insn_read && !insn_waitrequest) begin
					insn_address <= insn_address + 1;
					code_fetch_ptr <= code_fetch_ptr + 1;

					if (code_fetch_ptr == code_length) begin
						insn_address <= code_base;
						code_fetch_ptr <= 0;
					end
				end

				if (insn_readdatavalid) begin
					fifo_in.insn <= insn_readdata;
					fifo_in.clear_lanes <= code_read_ptr == 0;

					code_read_ptr <= code_read_ptr + 1;
					if (code_read_ptr == code_length)
						code_read_ptr <= 0;
				end
			end

			FLUSH:
				if (fifo_pending == 0) begin
					header_count <= header_count - 1;
					insn_address <= header_ptr;
				end
		endcase

endmodule
