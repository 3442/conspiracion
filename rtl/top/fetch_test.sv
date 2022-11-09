`timescale 1 ns / 1 ps
`include "core/uarch.sv"

module fetch_test
(
    input  logic clk,
	             stall,
	             branch,
	             prefetch_flush,
	             fetched,
	             wr_pc,
	input  ptr   branch_target,
	input  word  wr_current,
	             fetch_data,

	output logic fetch,
	output word  insn,
	output ptr   insn_pc,
	             addr

);

    core_fetch #(.PREFETCH_ORDER(3)) DUT (.flush(), .*);

endmodule
