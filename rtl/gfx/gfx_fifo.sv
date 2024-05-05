module gfx_fifo
#(int WIDTH = 0,
  int DEPTH = 0)
(
	input  logic        clk,
	                    rst_n,

	       gfx_beats.rx in,
	       gfx_beats.tx out
);

	logic do_read, do_write, full_if_eq, in_stall, out_stall,
	      may_read, may_write, read, read_ok, write;

	logic[WIDTH - 1:0] fifo[DEPTH], read_data, write_data;
	logic[$clog2(DEPTH) - 1:0] read_ptr, write_ptr;

	assign do_read = read & may_read;
	assign do_write = write & may_write;

	always_comb begin
		may_read = full_if_eq;
		may_write = !full_if_eq;

		if (read)
			may_write = 1;

		if (read_ptr != write_ptr) begin
			may_read = 1;
			may_write = 1;
		end
	end

	gfx_skid_flow in_flow
	(
		.clk,
		.rst_n,
		.stall(in_stall),
		.in_ready(in.ready),
		.in_valid(in.valid),
		.out_ready(may_write),
		.out_valid(write)
	);

	gfx_skid_flow out_flow
	(
		.clk,
		.rst_n,
		.stall(out_stall),
		.in_ready(read),
		.in_valid(read_ok),
		.out_ready(out.ready),
		.out_valid(out.valid)
	);

	gfx_skid_buf #(WIDTH) in_skid
	(
		.clk,
		.in(in.data),
		.out(write_data),
		.stall(in_stall)
	);

	gfx_skid_buf #(WIDTH) out_skid
	(
		.clk,
		.in(read_data),
		.out(out.data),
		.stall(out_stall)
	);

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			read_ok <= 0;
			read_ptr <= 0;
			write_ptr <= 0;
			full_if_eq <= 0;
		end else begin
			if (~out_stall)
				read_ok <= read && may_read;

			if (do_read)
				read_ptr <= read_ptr + 1;

			if (do_write)
				write_ptr <= write_ptr + 1;

			if (do_read & ~do_write)
				full_if_eq <= 0;
			else if (~do_read & do_write)
				full_if_eq <= 1;
		end

	always_ff @(posedge clk) begin
		if (~out_stall)
			read_data <= fifo[read_ptr];

		if (may_write)
			fifo[write_ptr] <= write_data;
	end

endmodule
