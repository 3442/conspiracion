`include "core/uarch.sv"

module core_control
(
	input  logic           clk,
	input  datapath_decode dec,
	input  branch_decode   dec_branch,
	input  data_decode     dec_data,
	input  snd_decode      dec_snd,
	input  ldst_decode     dec_ldst,
	input  mul_decode      dec_mul,
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
	input  logic           mul_ready,

`ifdef VERILATOR
	input  word            insn,
`endif

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
	                       mem_write,
	                       mul,
	                       mul_add,
	                       mul_long,
	                       mul_signed,
	                       coproc
);

	logic ldst, ldst_pre, ldst_increment, ldst_writeback, pop_valid;
	word mem_offset;
	reg_num r_shift, popped_upper, popped_lower, popped;
	reg_list mem_regs, next_regs_upper, next_regs_lower;

	assign reg_mode = `MODE_SVC; //TODO
	assign mem_data_wr = rd_value_b;
	assign popped = ldst_increment ? popped_lower : popped_upper;

	ctrl_cycle cycle, next_cycle;

	core_control_cycles ctrl_cycles
	(
		.*
	);

	logic bubble, next_bubble;

	core_control_stall ctrl_stall
	(
		.*
	);

	ptr pc /*verilator public*/, next_pc_visible;
	logic issue, undefined;

	core_control_issue ctrl_issue
	(
		.*
	);

	core_control_ldst_pop ctrl_ldst_pop
	(
		.regs(mem_regs),
		.valid(pop_valid),
		.next_upper(next_regs_upper),
		.next_lower(next_regs_lower),
		.pop_upper(popped_upper),
		.pop_lower(popped_lower)
	);

	core_control_branch ctrl_branch
	(
		.*
	);

	word saved_base;
	logic trivial_shift, data_snd_shift_by_reg;

	core_control_data ctrl_data
	(
		.*
	);

	logic final_writeback, final_update_flags;
	reg_num final_rd;

	core_control_writeback ctrl_wb
	(
		.*
	);

	word vector;
	logic exception;

	core_control_exception ctrl_exc
	(
		.*
	);

	always_ff @(posedge clk) begin
		wb_alu_flags <= alu_flags;

		unique case(next_cycle)
			ISSUE:
				if(issue) begin
					ra <= dec_data.rn;
					rb <= dec_snd.r;
					r_shift <= dec_snd.r_shift;

					// TODO: dec_ldst.unprivileged/user_regs
					// TODO: byte/halfword sizes
					ldst <= dec.ldst;
					ldst_pre <= dec_ldst.pre_indexed;
					ldst_increment <= dec_ldst.increment;
					ldst_writeback <= dec_ldst.writeback;

					mul <= dec.mul;
					mul_add <= dec_mul.add;
					mul_long <= dec_mul.long_mul;
					mul_signed <= dec_mul.signed_mul;

					coproc <= dec.coproc;

					mem_regs <= dec_ldst.regs;
					mem_write <= !dec_ldst.load;
				end

			RD_INDIRECT_SHIFT:
				rb <= r_shift;

			WITH_SHIFT: ;

			TRANSFER: begin
				if(cycle != TRANSFER) begin
					ldst <= 0;
					mem_offset <= alu_b;
				end

				if(cycle != TRANSFER || mem_ready) begin
					mem_regs <= ldst_increment ? next_regs_lower : next_regs_upper;
					mem_addr <= ldst_pre ? q_alu[31:2] : alu_a[31:2];

					if(pop_valid)
						rb <= popped;
					else
						rb <= final_rd; // Viene de dec_ldst.rd
				end

				mem_start <= cycle != TRANSFER || (mem_ready && pop_valid);
			end

			BASE_WRITEBACK: ;

			EXCEPTION: ;
		endcase
	end

	initial begin
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
	end

endmodule
