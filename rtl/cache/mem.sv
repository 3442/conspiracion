`include "cache/defs.sv"

module cache_mem
(
	input  logic      clk,
	                  rst_n,

	input  addr_tag   core_tag,

	// Señales para la SRAM
	input  addr_tag   tag_rd,		// valor de la tag de esa línea
	input  line       data_rd,		// datos de la línea

	input  addr_index index_wr,

	input  logic      mem_waitrequest,
	output word       mem_address,
	output logic      mem_read,
	                  mem_write,
	output line       mem_writedata,

	input  logic      mem_begin,
	                  writeback,
	output logic      mem_end,
	                  mem_read_end,
	                  mem_wait,
	output addr_tag   mem_tag,
	output addr_index mem_index
);

	assign mem_end = (mem_read || mem_write) && !mem_waitrequest;
	assign mem_wait = (mem_read || mem_write) && mem_waitrequest;
	assign mem_address = {`IO_CACHED, mem_tag, mem_index, 4'b0000};
	assign mem_read_end = mem_read && !mem_waitrequest;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			mem_read <= 0;
			mem_write <= 0;
		end else begin
			if (mem_end) begin
				mem_read <= 0;
				mem_write <= 0;
			end

			if (mem_begin) begin
				mem_read <= !writeback;
				mem_write <= writeback;
			end
		end

	always_ff @(posedge clk)
		if (mem_begin) begin
			mem_tag <= writeback ? tag_rd : core_tag;
			mem_index <= index_wr;
			mem_writedata <= data_rd;
		end

endmodule
