`include "cache/defs.sv"

module cache_routing
(
	input  logic       clk,
	                   rst_n,

	input  word        core_address,
	input  logic       core_read,
	                   core_write,
	input  line        core_writedata_line,
	input  line_be     core_byteenable_line,
	output logic       core_waitrequest,
	output line        core_readdata_line,

	output addr_tag    core_tag,
	output addr_index  core_index,
	output addr_offset core_offset,

	input  line        data_rd,
	input  logic       cache_core_waitrequest,
	output logic       cache_core_read,
	                   cache_core_write,

	input  word        cache_mem_address,
	input  logic       cache_mem_read,
	                   cache_mem_write,
	input  line        cache_mem_writedata,
	output logic       cache_mem_waitrequest,

	input  logic       mem_waitrequest,
	input  line        mem_readdata,
	output word        mem_address,
	output logic       mem_read,
	                   mem_write,
	output line        mem_writedata,
	output line_be     mem_byteenable
);

	word core_address_line;
	logic cached, cache_mem, transition;
	addr_mbz mbz;
	addr_io_region io;

	enum int unsigned
	{
		IDLE,
		CACHE,
		BYPASS
	} state;

	assign cached = io == 3'b000;
	assign cache_mem = cache_mem_read || cache_mem_write;

	assign {io, core_tag, core_index, core_offset, mbz} = core_address;
	assign core_address_line = {io, core_tag, core_index, 4'b0000};
	assign core_readdata_line = cached ? data_rd : mem_readdata;

	assign cache_core_read = core_read && cached;
	assign cache_core_write = core_write && cached;

	always_comb begin
		transition = 0;
		core_waitrequest = cache_core_waitrequest;
		cache_mem_waitrequest = 1;

		unique case (state)
			IDLE:
				transition = cache_mem || (!cached && (core_read || core_write));

			CACHE:
				cache_mem_waitrequest = mem_waitrequest;

			BYPASS:
				core_waitrequest = mem_waitrequest;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= IDLE;
			mem_read <= 0;
			mem_write <= 0;
		end else unique case (state)
			IDLE:
				if (transition) begin
					state <= cache_mem ? CACHE : BYPASS;
					mem_read <= cache_mem ? cache_mem_read : core_read;
					mem_write <= cache_mem ? cache_mem_write : core_write;
				end

			CACHE, BYPASS:
				if (!mem_waitrequest) begin
					state <= IDLE;
					mem_read <= 0;
					mem_write <= 0;
				end
		endcase

	always_ff @(posedge clk)
		if (transition) begin
			mem_address <= cache_mem ? cache_mem_address : core_address_line;
			mem_writedata <= cache_mem ? cache_mem_writedata : core_writedata_line;
			mem_byteenable <= cache_mem ? 16'hff : core_byteenable_line;
		end

endmodule
