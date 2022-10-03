`include "core/uarch.sv"

module core_psr
(
	input  logic     clk,
	                 update_flags,
	                 alu_v_valid,
	input  psr_flags alu_flags,

	output psr_flags flags
);

	psr_flags cpsr_flags;

	always_comb begin
		flags = cpsr_flags;

		if(update_flags) begin
			flags = alu_flags;
			if(~alu_v_valid)
				flags.v = cpsr_flags.v;
		end
	end

	always_ff @(posedge clk)
		cpsr_flags <= flags;

	initial cpsr_flags = 4'b0000;

endmodule
