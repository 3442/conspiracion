`include "core/uarch.sv"

module core_control_cycles
(
	input  logic      clk,
	                  mul,
	                  ldst,
	                  bubble,
	                  exception,
	                  mem_ready,
	                  mul_add,
	                  mul_long,
	                  mul_ready,
	                  pop_valid,
	                  trivial_shift,
	                  ldst_writeback,
	                  data_snd_shift_by_reg,

	output ctrl_cycle cycle,
	                  next_cycle
);

	always_comb begin
		next_cycle = ISSUE;

		unique0 case(cycle)
			ISSUE:
				if(exception)
					next_cycle = EXCEPTION;
				else if(mul)
					next_cycle = mul_add ? MUL_ACC_LD : MUL;
				else if(data_snd_shift_by_reg)
					next_cycle = RD_INDIRECT_SHIFT;
				else if(!trivial_shift)
					next_cycle = WITH_SHIFT;

			RD_INDIRECT_SHIFT:
				if(!trivial_shift)
					next_cycle = WITH_SHIFT;

			TRANSFER:
				if(!mem_ready || pop_valid)
					next_cycle = TRANSFER;
				else if(ldst_writeback)
					next_cycle = BASE_WRITEBACK;

			MUL:
				if(!mul_ready)
					next_cycle = MUL;
				else if(mul_long)
					next_cycle = MUL_HI_WB;

			MUL_ACC_LD:
				next_cycle = MUL;
		endcase

		if(bubble)
			next_cycle = ISSUE;
		else if(next_cycle == ISSUE && ldst) begin
			next_cycle = TRANSFER;
		end
	end

	always_ff @(posedge clk)
		cycle <= next_cycle;

	initial
		cycle = ISSUE;

endmodule
