`include "core/uarch.sv"

module core_fetch
#(parameter PREFETCH_ORDER=2)
(
	input  logic clk,
	             stall,
	             branch,
	             flush,
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

	ptr next_pc, head, hold_addr, target;
	logic fetched_valid, do_flush, discard;

	assign target = wr_pc ? wr_current[31:2] : branch_target; //TODO: alignment exception
	assign do_flush = branch || flush;
	assign fetched_valid = fetched && !discard;

	core_prefetch #(.ORDER(PREFETCH_ORDER)) prefetch
	(
		.flush(do_flush),
		.fetched(fetched_valid),
		.*
	);

	always_comb begin
		if(branch)
			head = target;
		else if(flush)
			head = next_pc;
		else
			head = {30{1'bx}};

		if(do_flush)
			addr = head;
		else if(fetch && fetched_valid)
			addr = hold_addr + 1;
		else
			addr = hold_addr;
	end

	always_ff @(posedge clk) begin
		discard <= discard ? ~fetched : do_flush & fetch;
		hold_addr <= addr;
	end

	initial begin
		discard = 0;
		hold_addr = 0;
	end

endmodule
