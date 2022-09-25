`include "core/uarch.sv"

module core_fetch
#(parameter PREFETCH_ORDER=2)
(
	input  logic clk,
	             stall,
	             flush,
	             fetched,
	input  word  fetch_data,
	input  ptr   target,

	output logic fetch,
	output word  insn,
	output ptr   insn_pc,
	             addr
);

	ptr next_pc;

	core_prefetch #(.ORDER(PREFETCH_ORDER)) prefetch
	(
		.*
	);

	always_ff @(posedge clk)
		if(flush)
			addr <= next_pc;
		else if(fetched)
			addr <= addr + 1;

	initial addr = 0;

endmodule
