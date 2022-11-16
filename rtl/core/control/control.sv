`include "core/uarch.sv"

module core_control
(
	input  logic           clk,
	                       rst_n,
	                       halt,

	input  insn_decode     dec,
	input  ptr             insn_pc,
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
	input  word            mul_q_hi,
	                       mul_q_lo,

`ifdef VERILATOR
	input  word            insn,
`endif

	output logic           halted,
	                       stall,
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
	output word            shifter_base,
	output logic[7:0]      shifter_shift,
	output ptr             mem_addr,
	output word            mem_data_wr,
	output logic           mem_start,
	                       mem_write,
	output word            mul_a,
	                       mul_b,
	                       mul_c_hi,
	                       mul_c_lo,
	output logic           mul_add,
	                       mul_long,
	                       mul_start,
	                       mul_signed,
	                       coproc
);

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

	core_control_select ctrl_select
	(
		.*
	);

	word mem_offset, ldst_read;
	logic ldst, ldst_next, ldst_writeback, pop_valid;
	reg_num popped;
	logic[1:0] ldst_shift;

	core_control_ldst ctrl_ldst
	(
		.*
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

	logic mul;
	reg_num mul_r_add_hi, mul_r_add_lo;

	core_control_mul ctrl_mul
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

	core_control_coproc ctrl_cp
	(
		.*
	);

endmodule
