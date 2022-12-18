`include "core/uarch.sv"

module core_control_ldst
(
	input  logic       clk,
	                   rst_n,

	input  insn_decode dec,
	input  logic       issue,
	                   mem_ready,
	input  word        rd_value_b,
	                   q_alu,
	                   q_shifter,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  word        alu_a,
	                   alu_b,

	output ptr         mem_addr,
	output logic[3:0]  mem_data_be,
	output word        mem_data_wr,
	                   mem_offset,
	output logic       mem_start,
	                   mem_write,
	                   mem_user,
	                   pop_valid,
	                   ldst,
	                   ldst_next,
	                   ldst_writeback,
	output logic[1:0]  ldst_shift,
	output word        ldst_read,
	output reg_num     popped
);

	word base;
	logic pre, increment, sign_extend;
	reg_num popped_upper, popped_lower;
	reg_list mem_regs, next_regs_upper, next_regs_lower;
	ldst_size size;

	assign popped = increment ? popped_lower : popped_upper;
	assign ldst_next = !cycle.transfer || mem_ready;
	assign mem_data_wr = q_shifter;

	core_control_ldst_pop pop
	(
		.regs(mem_regs),
		.valid(pop_valid),
		.next_upper(next_regs_upper),
		.next_lower(next_regs_lower),
		.pop_upper(popped_upper),
		.pop_lower(popped_lower)
	);

	core_control_ldst_sizes sizes
	(
		.addr(mem_addr),
		.read(ldst_read),
		.shift(ldst_shift),
		.fault(), //TODO: alignment check
		.byteenable(mem_data_be),
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pre <= 0;
			ldst <= 0;
			size <= LDST_WORD;
			increment <= 0;
			sign_extend <= 0;
			ldst_writeback <= 0;

			base <= {$bits(base){1'b0}};
			mem_regs <= {$bits(mem_regs){1'b0}};
			mem_user <= 0;
			mem_write <= 0;
			mem_start <= 0;
			mem_offset <= 0;
		end else begin
			if(mem_start)
				mem_start <= 0;

			if(next_cycle.issue) begin
				if(issue) begin
					ldst <= dec.ctrl.ldst;
					mem_user <= dec.ldst.unprivileged;
				end

				pre <= dec.ldst.pre_indexed;
				size <= dec.ldst.size;
				increment <= dec.ldst.increment;
				sign_extend <= dec.ldst.sign_extend;
				ldst_writeback <= dec.ldst.writeback;

				mem_regs <= dec.ldst.regs;
				mem_write <= !dec.ldst.load;
			end else if(next_cycle.transfer) begin
				if(!cycle.transfer) begin
					ldst <= 0;
					mem_offset <= alu_b;
				end

				if(ldst_next) begin
					base <= pre ? q_alu : alu_a;
					mem_regs <= increment ? next_regs_lower : next_regs_upper;
				end

				mem_start <= !cycle.transfer || (mem_ready && pop_valid);
			end else if(cycle.escalate)
				ldst <= 0;
		end
endmodule
