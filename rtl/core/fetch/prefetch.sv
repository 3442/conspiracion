`include "core/uarch.sv"

module core_prefetch
#(parameter ORDER=2)
(
	input  logic clk,
	             rst_n,
	             stall,
	             flush,
	             fault,
	             fetched,
	input  word  fetch_data,
	input  ptr   head,

	output word  insn,
	output ptr   insn_pc,
	output logic fetch,
	             nop,
	             insn_abort
);

	localparam SIZE = (1 << ORDER) - 1;

	ptr next_pc;
	logic faults[SIZE];
	logic[31:0] prefetch[SIZE];
	logic[ORDER - 1:0] valid;

	assign nop = flush ? 1 : ~|valid;
	assign insn = flush ? `NOP : prefetch[0];
	assign fetch = !stall || ~&valid;
	assign next_pc = ~stall & |valid ? insn_pc + 1 : insn_pc;
	assign insn_abort = flush ? 0 : faults[0];

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			valid <= 0;
			insn_pc <= 0;

			faults[SIZE - 1] <= 0;
			prefetch[SIZE - 1] <= `NOP;
		end else begin
			insn_pc <= flush ? head : next_pc;

			if(flush) begin
				faults[SIZE - 1] <= 0;
				prefetch[SIZE - 1] <= `NOP;
			end else if(fetched && valid == SIZE - 1 + {{(ORDER - 1){1'b0}}, !stall}) begin
				faults[SIZE - 1] <= fault;
				prefetch[SIZE - 1] <= fetch_data;
			end else if(!stall) begin
				faults[SIZE - 1] <= 0;
				prefetch[SIZE - 1] <= `NOP;
			end

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
			always_ff @(posedge clk or negedge rst_n)
				if(!rst_n) begin
					faults[i] <= 0;
					prefetch[i] <= `NOP;
				end else if(flush) begin
					faults[i] <= 0;
					prefetch[i] <= `NOP;
			end else if(fetched & (~(|i | |valid) | (valid == i + {{(ORDER - 1){1'b0}}, ~stall}))) begin
					faults[i] <= fault;
					prefetch[i] <= fetch_data;
				end else if(~stall) begin
					faults[i] <= faults[i + 1];
					prefetch[i] <= prefetch[i + 1];
				end
		end
	endgenerate

endmodule
