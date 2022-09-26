`include "core/uarch.sv"

module core_prefetch
#(parameter ORDER=2)
(
	input  logic       clk,
	                   stall,
	                   flush,
	                   fetched,
	input  logic[31:0] fetch_data,

	output logic[31:0] insn,
	output logic[29:0] insn_pc,
	                   next_pc,
	output logic       fetch
);

	localparam SIZE = (1 << ORDER) - 1;

	logic[31:0] prefetch[SIZE];
	logic[ORDER - 1:0] valid;

	assign insn = ~flush ? prefetch[0] : `NOP;
	assign next_pc = ~stall & |valid ? insn_pc + 1 : insn_pc;

	always_comb
		if((valid == SIZE - 2) & fetched)
			fetch = 0;
		else
			fetch = ~&valid;

	always_ff @(posedge clk) begin
		insn_pc <= next_pc;

		if(~flush & fetched & (valid == SIZE - 1))
			prefetch[SIZE - 1] <= fetch_data;
		else
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
