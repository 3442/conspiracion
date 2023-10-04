`include "cache/defs.sv"

module cache
#(parameter TOKEN_AT_RESET=0)
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

	logic write_data, write_state;
	line data_wr, data_rd;
	addr_tag tag_wr, tag_rd;
	line_state state_wr, state_rd;
	addr_index index_rd, index_wr;

	cache_sram sram
	(
		.*
	);

	word cache_mem_address;
	line cache_mem_writedata;
	logic cache_core_waitrequest, cache_mem_waitrequest, cache_mem_read, cache_mem_write,
	      debug_ready;

	cache_control #(.TOKEN_AT_RESET(TOKEN_AT_RESET)) control
	(
		.core_read(cache_core_read),
		.core_write(cache_core_write),
		.core_waitrequest(cache_core_waitrequest),
		.mem_waitrequest(cache_mem_waitrequest),
		.mem_address(cache_mem_address),
		.mem_writedata(cache_mem_writedata),
		.mem_read(cache_mem_read),
		.mem_write(cache_mem_write),
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

	line core_writedata_line, core_data_wr;
	line_be core_byteenable_line;

	cache_offsets offsets
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

endmodule
