`include "cache/defs.sv"

module perf_link
(
	input  logic      clk,
	                  rst_n,

	input  logic      in_left_valid,
	input  ring_req   in_left,
	output logic      in_left_ready,

	input  logic      in_right_valid,
	input  ring_req   in_right,
	output logic      in_right_ready,

	input  logic      out_left_ready,
	output ring_req   out_left,
	output logic      out_left_valid,

	input  line_ptr   local_address,
	input  logic      local_read,
	                  local_write,
	input  line       local_writedata,
	input  line_be    local_byteenable,
	output logic      local_waitrequest,
	output line       local_readdata,

	input  logic      mem_waitrequest,
	input  line       mem_readdata,
	output word       mem_address,
	output logic      mem_read,
	                  mem_write,
	output line       mem_writedata,
	output line_be    mem_byteenable,

	input  logic      clear,
	input  logic[3:0] address,
	output word       readdata
);

	logic snoop_left_ready, snoop_left_valid, snoop_right_ready, snoop_right_valid,
	      snoop_read, snoop_write, snoop_waitrequest, cached;

	addr_bits snoop_addr_bits;
	perf_sample snoop_left, snoop_right;

	word reads, writes, ring_reads, ring_invals, ring_read_invals, ring_replies, ring_forwards,
	     io_reads, io_writes, snoop_address;

	hword mem_cycles, mem_cycles_hold, ring_cycles, min_ring_cycles, max_ring_cycles,
	      min_read_cycles, max_read_cycles, min_write_cycles, max_write_cycles;

	perf_snoop snoop
	(
		.*
	);

	assign cached = snoop_addr_bits.io == `IO_CACHED;
	assign mem_cycles = mem_cycles_hold + 1;
	assign snoop_addr_bits = snoop_address;

	always_comb
		if (!address[3]) unique case (address[2:0])
			3'b000: readdata = reads;
			3'b001: readdata = writes;
			3'b010: readdata = {max_read_cycles, min_read_cycles};
			3'b011: readdata = {max_write_cycles, min_write_cycles};
			3'b100: readdata = ring_reads;
			3'b101: readdata = ring_invals;
			3'b110: readdata = ring_read_invals;
			3'b111: readdata = ring_replies;
		endcase else unique case (address[1:0])
			2'b00:  readdata = ring_forwards;
			2'b01:  readdata = {max_ring_cycles, min_ring_cycles};
			2'b10:  readdata = io_reads;
			2'b11:  readdata = io_writes;
		endcase

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			reads <= 0;
			writes <= 0;
			io_reads <= 0;
			io_writes <= 0;

			min_ring_cycles <= 0;
			max_ring_cycles <= 0;
			min_read_cycles <= 0;
			max_read_cycles <= 0;
			min_write_cycles <= 0;
			max_write_cycles <= 0;

			ring_reads <= 0;
			ring_invals <= 0;
			ring_replies <= 0;
			ring_forwards <= 0;
			ring_read_invals <= 0;

			mem_cycles_hold <= 0;
		end else begin
			ring_cycles <= ring_cycles + 1;

			if (mem_read || mem_write)
				mem_cycles_hold <= mem_cycles;

			if ((mem_read || mem_write) && !mem_waitrequest) begin
				mem_cycles_hold <= 0;

				if (!cached) begin
					if (mem_write)
						io_writes <= io_writes + 1;
					else
						io_reads <= io_reads + 1;
				end else if (mem_write) begin
					writes <= writes + 1;

					if (min_write_cycles == 0 || mem_cycles_hold < min_write_cycles)
						min_write_cycles <= mem_cycles;

					if (mem_cycles_hold >= max_write_cycles)
						max_write_cycles <= mem_cycles;
				end else begin
					reads <= reads + 1;

					if (min_read_cycles == 0 || mem_cycles_hold < min_read_cycles)
						min_read_cycles <= mem_cycles;

					if (mem_cycles_hold >= max_read_cycles)
						max_read_cycles <= mem_cycles;
				end
			end

			if (snoop_left_valid && snoop_left_ready && snoop_left.ttl == `TTL_END) begin
				if (snoop_left.reply)
					ring_replies <= ring_replies + 1;

				if (min_ring_cycles == 0 || ring_cycles < min_ring_cycles)
					min_ring_cycles <= ring_cycles;

				if (ring_cycles > max_ring_cycles)
					max_ring_cycles <= ring_cycles;
			end

			if (snoop_right_valid && snoop_right_ready) begin
				if (snoop_right.ttl == `TTL_MAX) begin
					ring_cycles <= 1;

					if (snoop_right.read && !snoop_right.inval)
						ring_reads <= ring_reads + 1;

					if (!snoop_right.read && snoop_right.inval)
						ring_invals <= ring_invals + 1;

					if (snoop_right.read && snoop_right.inval)
						ring_read_invals <= ring_read_invals + 1;
				end else
					ring_forwards <= ring_forwards + 1;
			end

			if (clear) begin
				reads <= 0;
				writes <= 0;
				io_reads <= 0;
				io_writes <= 0;

				min_ring_cycles <= 0;
				max_ring_cycles <= 0;
				min_read_cycles <= 0;
				max_read_cycles <= 0;
				min_write_cycles <= 0;
				max_write_cycles <= 0;

				ring_reads <= 0;
				ring_invals <= 0;
				ring_replies <= 0;
				ring_forwards <= 0;
				ring_read_invals <= 0;
			end
		end

endmodule
