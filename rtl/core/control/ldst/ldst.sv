`include "core/uarch.sv"

module core_control_ldst
(
	input  logic           clk,

	input  datapath_decode dec,
	input  ldst_decode     dec_ldst,
	input  logic           issue,
	                       mem_ready,
	input  word            rd_value_b,
	                       q_alu,

	input  ctrl_cycle      cycle,
	                       next_cycle,
	input  word            alu_a,
	                       alu_b,

	output ptr             mem_addr,
	output word            mem_data_wr,
	                       mem_offset,
	output logic           mem_start,
	                       mem_write,
	                       pop_valid,
	                       ldst,
	                       ldst_writeback,
	output reg_num         popped
);

	logic ldst_pre, ldst_increment;
	reg_num popped_upper, popped_lower;
	reg_list mem_regs, next_regs_upper, next_regs_lower;

	assign mem_data_wr = rd_value_b;
	assign popped = ldst_increment ? popped_lower : popped_upper;

	core_control_ldst_pop pop
	(
		.regs(mem_regs),
		.valid(pop_valid),
		.next_upper(next_regs_upper),
		.next_lower(next_regs_lower),
		.pop_upper(popped_upper),
		.pop_lower(popped_lower)
	);

	always_ff @(posedge clk)
		unique0 case(next_cycle)
			ISSUE:
				if(issue) begin
					// TODO: dec_ldst.unprivileged/user_regs
					// TODO: byte/halfword sizes
					ldst <= dec.ldst;
					ldst_pre <= dec_ldst.pre_indexed;
					ldst_increment <= dec_ldst.increment;
					ldst_writeback <= dec_ldst.writeback;

					mem_regs <= dec_ldst.regs;
					mem_write <= !dec_ldst.load;
				end

			TRANSFER: begin
				if(cycle != TRANSFER) begin
					ldst <= 0;
					mem_offset <= alu_b;
				end

				if(cycle != TRANSFER || mem_ready) begin
					mem_regs <= ldst_increment ? next_regs_lower : next_regs_upper;
					mem_addr <= ldst_pre ? q_alu[31:2] : alu_a[31:2];
				end

				mem_start <= cycle != TRANSFER || (mem_ready && pop_valid);
			end
		endcase

	initial begin
		ldst = 0;
		ldst_pre = 0;
		ldst_writeback = 0;
		ldst_increment = 0;

		mem_addr = {$bits(mem_addr){1'b0}};
		mem_write = 0;
		mem_start = 0;
		mem_regs = {$bits(mem_regs){1'b0}};
		mem_offset = 0;
	end

endmodule
