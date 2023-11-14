module gfx_fifo
#(parameter WIDTH=0, DEPTH=0)
(
	input  logic              clk,
	                          rst_n,

	input  logic[WIDTH - 1:0] in,
	input  logic              in_valid,
	output logic              in_ready,

	input  logic              out_ready,
	output logic              out_valid,
	output logic[WIDTH - 1:0] out
);

	logic full_if_eq, in_stall, out_stall, may_read, may_write, read, read_ok, write;
	logic[WIDTH - 1:0] fifo[DEPTH], read_data, write_data;
	logic[$clog2(DEPTH) - 1:0] read_ptr, write_ptr;

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
		.stall(in_stall),
		.out_ready(may_write),
		.out_valid(write),
		.*
	);

	gfx_skid_flow out_flow
	(
		.stall(out_stall),
		.in_ready(read),
		.in_valid(read_ok),
		.*
	);

	gfx_skid_buf #(.WIDTH(WIDTH)) in_skid
	(
		.out(write_data),
		.stall(in_stall),
		.*
	);

	gfx_skid_buf #(.WIDTH(WIDTH)) out_skid
	(
		.in(read_data),
		.stall(out_stall),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			read_ok <= 0;
			read_ptr <= 0;
			write_ptr <= 0;
			full_if_eq <= 0;
		end else begin
			if (!out_stall)
				read_ok <= read && may_read;

			if (read && may_read)
				read_ptr <= read_ptr + 1;

			if (write && may_write)
				write_ptr <= write_ptr + 1;

			if (read && !write)
				full_if_eq <= 0;
			else if (!read && write)
				full_if_eq <= 1;
		end

	always_ff @(posedge clk) begin
		if (!out_stall)
			read_data <= fifo[read_ptr];

		if (may_write)
			fifo[write_ptr] <= write_data;
	end

endmodule
