`include "core/uarch.sv"

module core_fetch
#(parameter PREFETCH_ORDER=2)
(
	input  logic       clk,
	                   stall,
	                   flush,
	                   fetched,
	input  logic[31:0] fetch_data,

	output logic       fetch,
	output logic[31:0] insn,
	output logic[29:0] insn_pc,
	                   addr
);

	logic[29:0] next_pc;

	core_prefetch #(.ORDER(PREFETCH_ORDER)) prefetch
	(
		.*
	);

	always_ff @(posedge clk)
		if(flush)
			addr <= next_pc;
		else if(fetched)
			addr <= addr + 1;

	initial begin
		addr = 0;
	end

endmodule
