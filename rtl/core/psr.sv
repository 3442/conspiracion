`include "core/uarch.sv"

module core_psr
(
	input  logic     clk,
	                 update_flags,
	                 alu_v_valid,
	input  psr_flags alu_flags,

	output psr_flags flags
);

	psr_flags next_flags;

	always_comb begin
		next_flags = flags;

		if(update_flags) begin
			next_flags = alu_flags;
			if(~alu_v_valid)
				next_flags.v = flags.v;
		end
	end

	always_ff @(posedge clk)
		flags <= next_flags;

	initial flags = 4'b0000;

endmodule
