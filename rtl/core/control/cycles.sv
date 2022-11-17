`include "core/uarch.sv"

module core_control_cycles
(
	input  logic      clk,
	                  rst_n,
	                  halt,
	                  mul,
	                  psr,
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

	/* qts-qii51007-recommended-hdl.pdf, p. 66
	 * In Quartus II integrated synthesis, the enumerated type that defines the states for the
	 * state machine must be of an unsigned integer type as in Example 13–52. If you do not
	 * specify the enumerated type as int unsigned, a signed int type is used by default. In
	 * this case, the Quartus II integrated synthesis synthesizes the design, but does not infer
	 * or optimize the logic as a state machine.
	 */
	enum int unsigned
	{
		ISSUE,
		RD_INDIRECT_SHIFT,
		WITH_SHIFT,
		TRANSFER,
		BASE_WRITEBACK,
		ESCALATE,
		EXCEPTION,
		MUL,
		MUL_ACC_LD,
		MUL_HI_WB,
		PSR
	} state, next_state;

	// TODO: debe estar escrito de tal forma que Quartus infiera una FSM

	assign cycle.issue = state == ISSUE;
	assign cycle.rd_indirect_shift = state == RD_INDIRECT_SHIFT;
	assign cycle.with_shift = state == WITH_SHIFT;
	assign cycle.transfer = state == TRANSFER;
	assign cycle.base_writeback = state == BASE_WRITEBACK;
	assign cycle.escalate = state == ESCALATE;
	assign cycle.exception = state == EXCEPTION;
	assign cycle.mul = state == MUL;
	assign cycle.mul_acc_ld = state == MUL_ACC_LD;
	assign cycle.mul_hi_wb = state == MUL_HI_WB;
	assign cycle.psr = state == PSR;

	assign next_cycle.issue = next_state == ISSUE;
	assign next_cycle.rd_indirect_shift = next_state == RD_INDIRECT_SHIFT;
	assign next_cycle.with_shift = next_state == WITH_SHIFT;
	assign next_cycle.transfer = next_state == TRANSFER;
	assign next_cycle.base_writeback = next_state == BASE_WRITEBACK;
	assign next_cycle.escalate = next_state == ESCALATE;
	assign next_cycle.exception = next_state == EXCEPTION;
	assign next_cycle.mul = next_state == MUL;
	assign next_cycle.mul_acc_ld = next_state == MUL_ACC_LD;
	assign next_cycle.mul_hi_wb = next_state == MUL_HI_WB;
	assign next_cycle.psr = next_state == PSR;

	always_comb begin
		next_state = ISSUE;

		unique case(state)
			ISSUE:
				if(exception)
					next_state = ESCALATE;
				else if(halt)
					next_state = ISSUE;
				else if(mul)
					next_state = mul_add ? MUL_ACC_LD : MUL;
				else if(data_snd_shift_by_reg)
					next_state = RD_INDIRECT_SHIFT;
				else if(!trivial_shift)
					next_state = WITH_SHIFT;

			RD_INDIRECT_SHIFT:
				if(!trivial_shift)
					next_state = WITH_SHIFT;

			ESCALATE:
				next_state = EXCEPTION;

			TRANSFER:
				if(!mem_ready || pop_valid)
					next_state = TRANSFER;
				else if(ldst_writeback)
					next_state = BASE_WRITEBACK;

			MUL:
				if(!mul_ready)
					next_state = MUL;
				else if(mul_long)
					next_state = MUL_HI_WB;

			MUL_ACC_LD:
				next_state = MUL;

			/* Este default evita problemas de sintetizado, ya que Quartus
			 * asume que los casos mencionados son exhaustivos, provocando
			 * bugs muy difíciles de depurar. No es lo mismo que si se quita
			 * default.
			 */
			default: ;
		endcase

		if(bubble)
			next_state = ISSUE;
		else if(next_state == ISSUE) begin
			if(ldst)
				next_state = TRANSFER;
			else if(psr)
				next_state = PSR;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		state <= !rst_n ? ISSUE : next_state;

endmodule
