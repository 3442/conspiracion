`include "core/uarch.sv"

module core_fetch
#(parameter PREFETCH_ORDER=2)
(
	input  logic clk,
	             stall,
	             branch,
	             flush,
	             fetched,
	input  word  fetch_data,
	input  ptr   target,

	output logic fetch,
	output word  insn,
	output ptr   insn_pc,
	             addr
);

	ptr next_pc, head;
	logic fetched_valid, do_flush, discard;

	assign do_flush = branch | flush;
	assign fetched_valid = fetched & ~discard;

	core_prefetch #(.ORDER(PREFETCH_ORDER)) prefetch
	(
		.flush(do_flush),
		.fetched(fetched_valid),
		.*
	);

	always_comb
		if(branch)
			head = target;
		else if(flush)
			head = next_pc;
		else
			head = {30{1'bx}};

	always_ff @(posedge clk) begin
		if(do_flush)
			addr <= head;
		else if(fetched_valid)
			addr <= addr + 1;

		discard <= discard ? ~fetched : do_flush & fetch;
	end

	initial begin
		addr = 0;
		discard = 0;
	end

endmodule
