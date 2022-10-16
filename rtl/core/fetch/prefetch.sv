`include "core/uarch.sv"

module core_prefetch
#(parameter ORDER=2)
(
	input  logic clk,
	             stall,
	             flush,
	             fetched,
	input  word  fetch_data,
	input  ptr   head,

	output word  insn,
	output ptr   insn_pc,
	             next_pc,
	output logic fetch
);

	localparam SIZE = (1 << ORDER) - 1;

	logic[31:0] prefetch[SIZE];
	logic[ORDER - 1:0] valid;

	assign insn = flush ? `NOP : prefetch[0];
	assign next_pc = ~stall & |valid ? insn_pc + 1 : insn_pc;
	assign fetch = !stall || ~&valid;

	always_ff @(posedge clk) begin
		insn_pc <= flush ? head : next_pc;

		if(flush)
			prefetch[SIZE - 1] <= `NOP;
		else if(fetched && valid == SIZE - 1 + {{(ORDER - 1){1'b0}}, !stall})
			prefetch[SIZE - 1] <= fetch_data;
		else if(!stall)
			prefetch[SIZE - 1] <= `NOP;

		if(flush)
			valid <= 0;
		else if(fetched & ((stall & ~&valid) | ~|valid))
			valid <= valid + 1;
		else if(~stall & ~fetched & |valid)
			valid <= valid - 1;
	end

	genvar i;
	generate
		for(i = 0; i < SIZE - 1; ++i) begin: prefetch_slots
			always_ff @(posedge clk)
				if(flush)
					prefetch[i] <= `NOP;
				else if(fetched & (~(|i | |valid) | (valid == i + {{(ORDER - 1){1'b0}}, ~stall})))
					prefetch[i] <= fetch_data;
				else if(~stall)
					prefetch[i] <= prefetch[i + 1];

			initial prefetch[i] = `NOP;
		end
	endgenerate

	initial begin
		insn_pc = 0;
		valid = 0;
		prefetch[SIZE - 1] = `NOP;
	end

endmodule
