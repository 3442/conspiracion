`include "core/uarch.sv"

module arm810
(
	input  logic       clk,

	output logic[29:0] bus_addr,
	output logic       bus_start,
	                   bus_write,
	input  logic       bus_ready,
	input  logic[31:0] bus_data_rd,
	output logic[31:0] bus_data_wr
);

	logic stall, prefetch_flush;
	logic[31:0] insn;
	logic[29:0] insn_pc;

	psr_flags flags;
	assign flags = 4'b1010;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.flush(prefetch_flush),
		.addr(bus_addr),
		.fetched(bus_ready),
		.fetch_data(bus_data_rd),
		.fetch(bus_start),
		.*
	);

	//TODO
	logic execute, undefined;
	core_decode decode
	(
		.*
	);

endmodule
