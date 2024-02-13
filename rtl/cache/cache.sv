`include "cache/defs.sv"
`include "config.sv"

module cache
#(parameter ID=0)
(
	input  logic      clk,
					  rst_n,

	input  ptr        core_address,
	input  logic      core_read,
					  core_write,
					  core_lock,
	input  word       core_writedata,
	input  word_be    core_byteenable,
	output logic      core_waitrequest,
	output logic[1:0] core_response,
	output word       core_readdata,

	input  logic[2:0] dbg_address,
	input  logic      dbg_read,
					  dbg_write,
	input  word       dbg_writedata,
	output logic      dbg_waitrequest,
	output word       dbg_readdata,

	input  logic      mem_waitrequest,
	input  line       mem_readdata,
	output word       mem_address,
	output logic      mem_read,
					  mem_write,
	output line       mem_writedata,
	output line_be    mem_byteenable,

	input  logic      in_data_valid,
	input  ring_req   in_data,
	output logic      in_data_ready,

	input  logic      out_data_ready,
	output ring_req   out_data,
	output logic      out_data_valid,

	input  ring_token in_token,
	input  logic      in_token_valid,

	output ring_token out_token,
	output logic      out_token_valid
);

	line cache_mem_writedata, data_rd;
	word cache_mem_address;
	logic cache_core_waitrequest, cache_mem_waitrequest, cache_mem_read, cache_mem_write;

	line core_writedata_line, core_data_wr;
	line_be core_byteenable_line;

	cache_offsets offsets
	(
		.*
	);

	line core_readdata_line;
	logic cache_core_read, cache_core_write;
	addr_tag core_tag;
	addr_index core_index;
	addr_offset core_offset;

	cache_routing routing
	(
		.*
	);

	generate
		if (ID < `CONFIG_CPUS && `CONFIG_CACHE) begin: enable
			logic write_data, write_state;
			line data_wr;
			addr_tag tag_wr, tag_rd;
			line_state state_wr, state_rd;
			addr_index index_rd, index_wr;

			cache_sram sram
			(
				.*
			);

			logic debug_ready, send, send_read, send_inval, set_reply, lock_line, unlock_line, mem_begin, writeback;

			cache_control control
			(
				.core_read(cache_core_read),
				.core_write(cache_core_write),
				.core_waitrequest(cache_core_waitrequest),

				.*
			);

			logic mem_end, mem_read_end, mem_wait;

			addr_tag mem_tag;
			addr_index mem_index;

			cache_mem mem
			(
				.mem_waitrequest(cache_mem_waitrequest),
				.mem_address(cache_mem_address),
				.mem_writedata(cache_mem_writedata),
				.mem_read(cache_mem_read),
				.mem_write(cache_mem_write),

				.*
			);

			logic locked, may_send;

			cache_token #(.TOKEN_AT_RESET(ID == 0)) token
			(
				.*
			);

			logic in_hold_valid, last_hop, out_stall;
			ring_req in_hold;

			cache_ring ring
			(
				.*
			);

			line monitor_update;
			logic monitor_acquire, monitor_commit, monitor_fail, monitor_release;

			cache_monitor monitor
			(
				.*
			);

			addr_index debug_index;

			cache_debug debug
			(
				.*
			);
		end else begin
			assign dbg_waitrequest = 0;

			assign cache_mem_read = 0;
			assign cache_mem_write = 0;
			assign cache_core_waitrequest = 1;

			if (`CONFIG_CACHE) begin: null_ring
				assign in_data_ready = out_data_ready;

				ring_req null_fwd;
				assign out_data = null_fwd;
				assign out_data_valid = in_data_valid;

				always_comb begin
					null_fwd = in_data;
					null_fwd.ttl = in_data.ttl - 1;
				end

				assign out_token = in_token;
				assign out_token_valid = in_token_valid;
			end
		end
	endgenerate

endmodule
