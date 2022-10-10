`include "core/uarch.sv"

module core_cycles
(
	input  logic           clk,
	                       dec_execute,
	                       dec_branch,
	                       dec_writeback,
	                       dec_update_flags,
	input  ptr             dec_branch_offset,
	input  snd_decode      dec_snd,
	input  data_decode     dec_data,
	input  ldst_decode     dec_ldst,
	input  ptr             fetch_insn_pc,
	input  psr_flags       flags,
	input  word            rd_value_a,
	                       rd_value_b,
	                       q_alu,
	                       q_shifter,
	input  logic           c_shifter,
	                       mem_ready,
	input  word            mem_data_rd,

	output logic           stall,
	                       branch,
	                       writeback,
	                       update_flags,
	                       c_in,
	output reg_num         rd,
	                       ra,
	                       rb,
	output ptr             branch_target,
	                       pc_visible,
	output psr_mode        reg_mode,
	output alu_op          alu,
	output word            alu_a,
	                       alu_b,
	                       wr_value,
	output shifter_control shifter,
	output logic[7:0]      shifter_shift,
	output ptr             mem_addr,
	output word            mem_data_wr,
	output logic           mem_start,
	                       mem_write
);

	enum
	{
		ISSUE,
		RD_INDIRECT_SHIFT,
		WITH_SHIFT,
		TRANSFER,
		BASE_WRITEBACK
	} cycle, next_cycle;

	logic bubble, final_writeback, final_update_flags,
	      ldst, ldst_pre, ldst_increment, ldst_writeback, pop_valid,
	      data_snd_is_imm, data_snd_shift_by_reg, trivial_shift;

	logic[5:0] data_shift_imm;
	logic[11:0] data_imm;
	word saved_base, mem_offset;
	reg_num r_shift, final_rd, popped_upper, popped_lower, popped;
	reg_list mem_regs, next_regs_upper, next_regs_lower;
	ptr pc;

	assign stall = (next_cycle != ISSUE) | bubble;
	assign pc_visible = pc + 2;
	assign reg_mode = `MODE_SVC; //TODO
	assign trivial_shift = shifter_shift == 0;
	assign mem_data_wr = rd_value_b;
	assign popped = ldst_increment ? popped_lower : popped_upper;

	core_cycles_ldst_pop ldst_pop
	(
		.regs(mem_regs),
		.valid(pop_valid),
		.next_upper(next_regs_upper),
		.next_lower(next_regs_lower),
		.pop_upper(popped_upper),
		.pop_lower(popped_lower)
	);

	always_comb begin
		unique case(cycle)
			RD_INDIRECT_SHIFT: shifter_shift = rd_value_b[7:0];
			default:           shifter_shift = {2'b00, data_shift_imm};
		endcase

		next_cycle = ISSUE;

		unique case(cycle)
			ISSUE:
				if(data_snd_shift_by_reg)
					next_cycle = RD_INDIRECT_SHIFT;
				else if(~trivial_shift)
					next_cycle = WITH_SHIFT;

			RD_INDIRECT_SHIFT:
				if(~trivial_shift)
					next_cycle = WITH_SHIFT;

			TRANSFER:
				if(!mem_ready || pop_valid)
					next_cycle = TRANSFER;
				else if(ldst_writeback)
					next_cycle = BASE_WRITEBACK;

			default: ;
		endcase

		if(bubble)
			next_cycle = ISSUE;
		else if(next_cycle == ISSUE && ldst)
			next_cycle = TRANSFER;

		unique case(cycle)
			TRANSFER: alu_a = saved_base;
			default:  alu_a = rd_value_a;
		endcase

		unique case(cycle)
			RD_INDIRECT_SHIFT, WITH_SHIFT:
				alu_b = saved_base;

			TRANSFER:
				alu_b = mem_offset;

			default:
				if(data_snd_is_imm)
					alu_b = {{20{1'b0}}, data_imm};
				else
					alu_b = rd_value_b;
		endcase
	end

	always_ff @(posedge clk) begin
		cycle <= next_cycle;
		bubble <= 0;
		branch <= 0;
		writeback <= 0;

		unique case(cycle)
			TRANSFER:       wr_value <= mem_data_rd;
			BASE_WRITEBACK: wr_value <= saved_base;
			default:        wr_value <= q_alu;
		endcase

		unique case(next_cycle)
			ISSUE: begin
				final_writeback <= 0;
				final_update_flags <= 0;

				if(dec_execute & ~bubble) begin
					bubble <=
						  (dec_update_flags & update_flags)
						| (final_writeback & ((rd == dec_data.rn) | (rd == dec_snd.r)));

					branch <= dec_branch;
					branch_target <= pc_visible + dec_branch_offset;

					alu <= dec_data.op;
					ra <= dec_data.rn;

					data_snd_is_imm <= dec_snd.is_imm;
					data_snd_shift_by_reg <= dec_snd.shift_by_reg;
					data_imm <= dec_snd.imm;
					data_shift_imm <= dec_snd.shift_imm;

					shifter.shl <= dec_snd.shl;
					shifter.shr <= dec_snd.shr;
					shifter.ror <= dec_snd.ror;
					shifter.put_carry <= dec_snd.put_carry;
					shifter.sign_extend <= dec_snd.sign_extend;

					rb <= dec_snd.r;
					r_shift <= dec_snd.r_shift;
					c_in <= flags.c;

					// TODO: dec_ldst.unprivileged/user_regs
					// TODO: byte/halfword sizes
					ldst <= dec_ldst.enable;
					ldst_pre <= dec_ldst.pre_indexed;
					ldst_increment <= dec_ldst.increment;
					ldst_writeback <= dec_ldst.writeback;

					mem_regs <= dec_ldst.regs;
					mem_write <= !dec_ldst.load;

					final_rd <= dec_data.rd;
					final_writeback <= dec_writeback;
					final_update_flags <= dec_update_flags;
				end

				update_flags <= final_update_flags;
				writeback <= final_writeback;
				rd <= final_rd;
				pc <= fetch_insn_pc;
			end

			RD_INDIRECT_SHIFT: begin
				rb <= r_shift;
				data_snd_shift_by_reg <= 0;
				saved_base <= rd_value_b;
			end

			WITH_SHIFT: begin
				c_in <= c_shifter;
				saved_base <= q_shifter;
			end

			TRANSFER: begin
				if(cycle != TRANSFER) begin
					ldst <= 0;
					mem_offset <= alu_b;
				end

				if(mem_ready) begin
					wr_value <= mem_data_rd;
					writeback <= !mem_write;
				end

				if(cycle != TRANSFER || mem_ready) begin
					mem_regs <= ldst_increment ? next_regs_lower : next_regs_upper;
					mem_addr <= ldst_pre ? q_alu[31:2] : alu_a[31:2];
					saved_base <= q_alu;

					if(pop_valid) begin
						rd <= popped;
						rb <= popped;
					end else
						rb <= final_rd; // Viene de dec_ldst.rd
				end

				mem_start <= cycle != TRANSFER || (mem_ready && pop_valid);
			end

			BASE_WRITEBACK: begin
				rd <= final_rd;
				wr_value <= mem_data_rd;
				writeback <= !mem_write;
				final_rd <= ra;
			end
		endcase
	end

	initial begin
		cycle = ISSUE;
		bubble = 0;

		pc = 0;
		c_in = 0;
		branch = 1;
		writeback = 0;
		branch_target = 30'd0;
		data_snd_shift_by_reg = 0;

		ldst = 0;
		ldst_pre = 0;
		ldst_writeback = 0;
		ldst_increment = 0;

		mem_addr = 30'b0;
		mem_write = 0;
		mem_start = 0;
		mem_regs = 16'b0;
		mem_offset = 0;

		final_rd = 0;
		final_writeback = 0;
	end

endmodule
