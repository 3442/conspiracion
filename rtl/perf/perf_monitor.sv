`include "cache/defs.sv"
`include "config.sv"

module perf_monitor
(
	input  logic      clk,
	                  rst_n,

	input  logic[5:0] perf_address,
	input  logic      perf_read,
	                  perf_write,
	input  word       perf_writedata, // No se usa
	output word       perf_readdata,

	input  logic      in_0_valid,
	input  ring_req   in_0,
	output logic      in_0_ready,

	input  logic      in_1_valid,
	input  ring_req   in_1,
	output logic      in_1_ready,

	input  logic      in_2_valid,
	input  ring_req   in_2,
	output logic      in_2_ready,

	input  logic      in_3_valid,
	input  ring_req   in_3,
	output logic      in_3_ready,

	input  logic      out_0_ready,
	output ring_req   out_0,
	output logic      out_0_valid,

	input  logic      out_1_ready,
	output ring_req   out_1,
	output logic      out_1_valid,

	input  logic      out_2_ready,
	output ring_req   out_2,
	output logic      out_2_valid,

	input  logic      out_3_ready,
	output ring_req   out_3,
	output logic      out_3_valid,

	input  line_ptr   local_0_address,
	input  logic      local_0_read,
	                  local_0_write,
	input  line       local_0_writedata,
	input  line_be    local_0_byteenable,
	output logic      local_0_waitrequest,
	output line       local_0_readdata,

	input  line_ptr   local_1_address,
	input  logic      local_1_read,
	                  local_1_write,
	input  line       local_1_writedata,
	input  line_be    local_1_byteenable,
	output logic      local_1_waitrequest,
	output line       local_1_readdata,

	input  line_ptr   local_2_address,
	input  logic      local_2_read,
	                  local_2_write,
	input  line       local_2_writedata,
	input  line_be    local_2_byteenable,
	output logic      local_2_waitrequest,
	output line       local_2_readdata,

	input  line_ptr   local_3_address,
	input  logic      local_3_read,
	                  local_3_write,
	input  line       local_3_writedata,
	input  line_be    local_3_byteenable,
	output logic      local_3_waitrequest,
	output line       local_3_readdata,

	input  logic      mem_0_waitrequest,
	input  line       mem_0_readdata,
	output word       mem_0_address,
	output logic      mem_0_read,
	                  mem_0_write,
	output line       mem_0_writedata,
	output line_be    mem_0_byteenable,

	input  logic      mem_1_waitrequest,
	input  line       mem_1_readdata,
	output word       mem_1_address,
	output logic      mem_1_read,
	                  mem_1_write,
	output line       mem_1_writedata,
	output line_be    mem_1_byteenable,

	input  logic      mem_2_waitrequest,
	input  line       mem_2_readdata,
	output word       mem_2_address,
	output logic      mem_2_read,
	                  mem_2_write,
	output line       mem_2_writedata,
	output line_be    mem_2_byteenable,

	input  logic      mem_3_waitrequest,
	input  line       mem_3_readdata,
	output word       mem_3_address,
	output logic      mem_3_read,
	                  mem_3_write,
	output line       mem_3_writedata,
	output line_be    mem_3_byteenable
);

	word readdata_0, readdata_1, readdata_2, readdata_3;
	logic clear_0, clear_1, clear_2, clear_3;
	logic[3:0] address;

	perf_link link_0
	(
		.in_left_valid(in_3_valid),
		.in_left(in_3),
		.in_left_ready(in_3_ready),

		.in_right_valid(in_0_valid),
		.in_right(in_0),
		.in_right_ready(in_0_ready),

		.out_left_ready(out_0_ready),
		.out_left(out_0),
		.out_left_valid(out_0_valid),

		.local_address(local_0_address),
		.local_read(local_0_read),
		.local_write(local_0_write),
		.local_writedata(local_0_writedata),
		.local_byteenable(local_0_byteenable),
		.local_waitrequest(local_0_waitrequest),
		.local_readdata(local_0_readdata),

		.mem_waitrequest(mem_0_waitrequest),
		.mem_readdata(mem_0_readdata),
		.mem_address(mem_0_address),
		.mem_read(mem_0_read),
		.mem_write(mem_0_write),
		.mem_writedata(mem_0_writedata),
		.mem_byteenable(mem_0_byteenable),

		.clear(clear_0),
		.readdata(readdata_0),
		.*
	);

	perf_link link_1
	(
		.in_left_valid(in_0_valid),
		.in_left(in_0),
		.in_left_ready(in_0_ready),

		.in_right_valid(in_1_valid),
		.in_right(in_1),
		.in_right_ready(in_1_ready),

		.out_left_ready(out_1_ready),
		.out_left(out_1),
		.out_left_valid(out_1_valid),

		.local_address(local_1_address),
		.local_read(local_1_read),
		.local_write(local_1_write),
		.local_writedata(local_1_writedata),
		.local_byteenable(local_1_byteenable),
		.local_waitrequest(local_1_waitrequest),
		.local_readdata(local_1_readdata),

		.mem_waitrequest(mem_1_waitrequest),
		.mem_readdata(mem_1_readdata),
		.mem_address(mem_1_address),
		.mem_read(mem_1_read),
		.mem_write(mem_1_write),
		.mem_writedata(mem_1_writedata),
		.mem_byteenable(mem_1_byteenable),

		.clear(clear_1),
		.readdata(readdata_1),
		.*
	);

	perf_link link_2
	(
		.in_left_valid(in_1_valid),
		.in_left(in_1),
		.in_left_ready(in_1_ready),

		.in_right_valid(in_2_valid),
		.in_right(in_2),
		.in_right_ready(in_2_ready),

		.out_left_ready(out_2_ready),
		.out_left(out_2),
		.out_left_valid(out_2_valid),

		.local_address(local_2_address),
		.local_read(local_2_read),
		.local_write(local_2_write),
		.local_writedata(local_2_writedata),
		.local_byteenable(local_2_byteenable),
		.local_waitrequest(local_2_waitrequest),
		.local_readdata(local_2_readdata),

		.mem_waitrequest(mem_2_waitrequest),
		.mem_readdata(mem_2_readdata),
		.mem_address(mem_2_address),
		.mem_read(mem_2_read),
		.mem_write(mem_2_write),
		.mem_writedata(mem_2_writedata),
		.mem_byteenable(mem_2_byteenable),

		.clear(clear_2),
		.readdata(readdata_2),
		.*
	);

	perf_link link_3
	(
		.in_left_valid(in_2_valid),
		.in_left(in_2),
		.in_left_ready(in_2_ready),

		.in_right_valid(in_3_valid),
		.in_right(in_3),
		.in_right_ready(in_3_ready),

		.out_left_ready(out_3_ready),
		.out_left(out_3),
		.out_left_valid(out_3_valid),

		.local_address(local_3_address),
		.local_read(local_3_read),
		.local_write(local_3_write),
		.local_writedata(local_3_writedata),
		.local_byteenable(local_3_byteenable),
		.local_waitrequest(local_3_waitrequest),
		.local_readdata(local_3_readdata),

		.mem_waitrequest(mem_3_waitrequest),
		.mem_readdata(mem_3_readdata),
		.mem_address(mem_3_address),
		.mem_read(mem_3_read),
		.mem_write(mem_3_write),
		.mem_writedata(mem_3_writedata),
		.mem_byteenable(mem_3_byteenable),

		.clear(clear_3),
		.readdata(readdata_3),
		.*
	);

	generate
		if (`CONFIG_PERF_MONITOR) begin: enable
			assign address = perf_address[3:0];

			always_comb begin
				clear_0 = 0;
				clear_1 = 0;
				clear_2 = 0;
				clear_3 = 0;

				unique case (perf_address[5:4])
					2'b00: begin
						clear_0 = perf_write;
						perf_readdata = readdata_0;
					end

					2'b01: begin
						clear_1 = perf_write;
						perf_readdata = readdata_1;
					end

					2'b10: begin
						clear_2 = perf_write;
						perf_readdata = readdata_2;
					end

					2'b11: begin
						clear_3 = perf_write;
						perf_readdata = readdata_3;
					end
				endcase
			end
		end
	endgenerate

endmodule
