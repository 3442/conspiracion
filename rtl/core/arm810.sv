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

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.flush(prefetch_flush),
		.addr(bus_addr),
		.fetched(bus_ready),
		.fetch_data(bus_data_rd),
		.fetch(bus_start),
		.*
	);

endmodule
