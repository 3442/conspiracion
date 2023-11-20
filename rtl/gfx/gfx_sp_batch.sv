`include "gfx/gfx_defs.sv"

module gfx_sp_batch
(
	input  logic          clk,
	                      rst_n,

	input  logic          batch_waitrequest,
	                      batch_readdatavalid,
	input  vram_word      batch_readdata,
	output vram_addr      batch_address,
	output logic          batch_read,

	input  logic          batch_start,
	input  vram_insn_addr batch_base,
	input  cmd_word       batch_length,

	output lane_word      out_data,
	output lane_mask      out_mask,
	input  logic          out_ready,
	output logic          out_valid
);

	localparam TAIL_BITS  = $clog2($bits(lane_mask)),
	           BLOCK_BITS = $bits(batch_length) - TAIL_BITS;

	logic fifo_down, fifo_up, lane_read, lane_readdatavalid, lane_waitrequest;
	lane_word lane_readdata;
	vram_lane_addr aligned_batch_base, lane_address;
	logic[TAIL_BITS - 1:0] batch_length_tail, read_tail;
	logic[BLOCK_BITS - 1:0] batch_length_block, fetch_block_count, read_block_count;
	logic[$clog2(`GFX_BATCH_FIFO_DEPTH + 1) - 1:0] fifo_pending;

	struct packed
	{
		lane_word data;
		lane_mask mask;
	} fifo_in, fifo_out;

	enum int unsigned
	{
		IDLE,
		STREAM
	} state;

	assign out_data = fifo_out.data;
	assign out_mask = fifo_out.mask;

	assign fifo_up = out_ready && out_valid;
	assign fifo_down = lane_read && !lane_waitrequest;
	assign fifo_in.data = lane_readdata;

	assign {batch_length_block, batch_length_tail} = batch_length;
	assign aligned_batch_base = batch_base[
		$bits(batch_base) - 1:$bits(batch_base) - $bits(vram_lane_addr)
	];

	gfx_sp_widener #(.WIDTH($bits(vram_lane_addr))) lane_bus
	(
		.wide_read(lane_read),
		.wide_address(lane_address),
		.wide_readdata(lane_readdata),
		.wide_waitrequest(lane_waitrequest),
		.wide_readdatavalid(lane_readdatavalid),
		.word_read(batch_read),
		.word_address(batch_address),
		.word_readdata(batch_readdata),
		.word_waitrequest(batch_waitrequest),
		.word_readdatavalid(batch_readdatavalid),
		.*
	);

	gfx_fifo #(.WIDTH($bits(fifo_in)), .DEPTH(`GFX_BATCH_FIFO_DEPTH)) lane_fifo
	(
		.in(fifo_in),
		.out(fifo_out),
		.in_ready(),
		.in_valid(lane_readdatavalid),
		.*
	);

	always_comb begin
		unique case (read_tail)
			2'b00: fifo_in.mask = 4'b0000;
			2'b01: fifo_in.mask = 4'b0001;
			2'b10: fifo_in.mask = 4'b0011;
			2'b11: fifo_in.mask = 4'b0111;
		endcase

		if (read_block_count == 0)
			fifo_in.mask = 4'b1111;
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= IDLE;
			lane_read <= 0;
			fifo_pending <= 0;
		end else begin
			unique case (state)
				IDLE:
					if (batch_start) begin
						state <= STREAM;
						lane_read <= 1;
					end

				STREAM: begin
					if (!lane_read || !lane_waitrequest)
						lane_read <= fifo_pending < `GFX_BATCH_FIFO_DEPTH - 1;

					if (lane_read && !lane_waitrequest && read_block_count == 0)
						state <= IDLE;
				end
			endcase

			if (fifo_up && !fifo_down)
				fifo_pending <= fifo_pending - 1;
			else if (!fifo_up && fifo_down)
				fifo_pending <= fifo_pending + 1;
		end

	always_ff @(posedge clk) begin
		unique case (state)
			IDLE:
				if (batch_start) begin
					read_tail <= batch_length_tail;
					read_block_count <= batch_length_block;
					fetch_block_count <= batch_length_block;

					lane_address <= aligned_batch_base;
				end

			STREAM:
				if (lane_read && !lane_waitrequest) begin
					lane_address <= lane_address + 1;
					fetch_block_count <= fetch_block_count - 1;
				end
		endcase

		if (lane_readdatavalid)
			read_block_count <= read_block_count - 1;
	end

endmodule
