`include "core/uarch.sv"

module core_control
(
	input  logic           clk,
	                       dec_execute,
	                       dec_undefined,
	                       dec_conditional,
	                       dec_uses_rn,
	                       dec_branch,
	                       dec_writeback,
	                       dec_update_flags,
	input  ptr             dec_branch_offset,
	input  snd_decode      dec_snd,
	input  data_decode     dec_data,
	input  ldst_decode     dec_ldst,
	input  ptr             fetch_insn_pc,
	input  psr_flags       flags,
	                       alu_flags,
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
	output psr_flags       wb_alu_flags,
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
		BASE_WRITEBACK,
		EXCEPTION
	} cycle, next_cycle;

	logic bubble, next_bubble, final_writeback, final_update_flags,
	      ldst, ldst_pre, ldst_increment, ldst_writeback, pop_valid,
	      data_snd_is_imm, data_snd_shift_by_reg, trivial_shift,
	      undefined, exception, high_vectors;

	logic[2:0] vector_offset;
	logic[5:0] data_shift_imm;
	logic[11:0] data_imm;
	word saved_base, mem_offset, vector;
	reg_num r_shift, final_rd, popped_upper, popped_lower, popped;
	reg_list mem_regs, next_regs_upper, next_regs_lower;
	ptr pc /*verilator public*/, next_pc_visible;

	assign stall = next_cycle != ISSUE || next_bubble;
	assign reg_mode = `MODE_SVC; //TODO
	assign trivial_shift = shifter_shift == 0;
	assign mem_data_wr = rd_value_b;
	assign popped = ldst_increment ? popped_lower : popped_upper;
	assign exception = undefined; //TODO
	assign high_vectors = 0; //TODO
	assign vector = {{16{high_vectors}}, 11'b0, vector_offset, 2'b00};
	assign next_pc_visible = fetch_insn_pc + 2;

	assign next_bubble =
		   (final_writeback && final_rd == `R15)
		|| ((dec_update_flags || dec_conditional) && (final_update_flags || update_flags))
		|| (final_writeback && ((dec_uses_rn && (final_rd == dec_data.rn || dec_data.rn == `R15))
		                      || final_rd == dec_snd.r || dec_snd.r == `R15));

	core_control_ldst_pop ldst_pop
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
				if(exception)
					next_cycle = EXCEPTION;
				else if(data_snd_shift_by_reg)
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
			TRANSFER:  alu_a = saved_base;
			EXCEPTION: alu_a = {pc, 2'b00};
			default:   alu_a = rd_value_a;
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

		vector_offset = 3'b001; //TODO
	end

	always_ff @(posedge clk) begin
		cycle <= next_cycle;
		bubble <= 0;
		branch <= 0;
		writeback <= 0;
		update_flags <= 0;
		wb_alu_flags <= alu_flags;

		unique case(cycle)
			TRANSFER:       wr_value <= mem_data_rd;
			BASE_WRITEBACK: wr_value <= saved_base;
			default:        wr_value <= q_alu;
		endcase

		unique case(next_cycle)
			ISSUE: begin
				final_writeback <= 0;
				final_update_flags <= 0;

				bubble <= next_bubble;

				if(dec_execute & ~next_bubble) begin
					branch <= dec_branch;
					branch_target <= next_pc_visible + dec_branch_offset;

					alu <= dec_data.op;
					ra <= dec_data.rn;

					data_snd_is_imm <= dec_snd.is_imm;
					data_snd_shift_by_reg <= dec_snd.shift_by_reg;
					data_imm <= dec_snd.imm;
					data_shift_imm <= dec_snd.shift_imm;

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
				undefined <= dec_undefined;

				rd <= final_rd;
				pc <= fetch_insn_pc;
				pc_visible <= next_pc_visible;
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

				writeback <= mem_ready && !mem_write;
				if(mem_ready) begin
					rd <= final_rd;
					wr_value <= mem_data_rd;
				end

				if(cycle != TRANSFER || mem_ready) begin
					mem_regs <= ldst_increment ? next_regs_lower : next_regs_upper;
					mem_addr <= ldst_pre ? q_alu[31:2] : alu_a[31:2];
					saved_base <= q_alu;

					if(pop_valid) begin
						rb <= popped;
						final_rd <= popped;
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

			EXCEPTION: begin
				//TODO: spsr_<mode> = cpsr
				//TODO: actualizar modo
				//TODO: deshabilitar IRQs/FIQs dependiendo de modo
				//TODO: Considerar que data abort usa + 8, no + 4
				rd <= `R15;
				wr_value <= vector;
				writeback <= 1;

				alu <= `ALU_ADD;
				data_imm <= 12'd4;
				data_snd_is_imm <= 1;

				final_rd <= `R14;
				final_writeback <= 1;
				final_update_flags <= 0;
			end
		endcase
	end

	initial begin
		cycle = ISSUE;
		bubble = 0;

		pc = 0;
		pc_visible = 2;

		c_in = 0;
		branch = 1;
		writeback = 0;
		branch_target = 30'd0;
		data_snd_shift_by_reg = 0;

		undefined = 0;

		wb_alu_flags = 4'b0000;

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
