`include "core/uarch.sv"

module arm810
(
	input  logic clk,

	output ptr   bus_addr,
	output logic bus_start,
	             bus_write,
	input  logic bus_ready,
	input  word  bus_data_rd,
	output word  bus_data_wr
);

	logic stall, prefetch_flush;
	word insn;
	ptr fetch_insn_pc, pc, pc_visible;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.flush(explicit_branch | wr_pc),
		.target(wr_pc ? wr_value[29:0] : branch_target),
		.addr(bus_addr),
		.fetched(bus_ready),
		.fetch_data(bus_data_rd),
		.fetch(bus_start),
		.insn_pc(fetch_insn_pc),
		.*
	);

	logic dec_execute, dec_undefined, dec_writeback, dec_branch, dec_update_flags;
	ptr dec_branch_offset;
	reg_num dec_rd;
	alu_op dec_data_op;

	core_decode decode
	(
		.flags(next_flags),
		.execute(dec_execute),
		.undefined(dec_undefined),
		.writeback(dec_writeback),
		.branch(dec_branch),
		.update_flags(dec_update_flags),
		.rd(dec_rd),
		.branch_offset(dec_branch_offset),
		.data_op(dec_data_op),
		.*
	);

	reg_num rd;
	logic explicit_branch, writeback, update_flags;
	ptr branch_target;
	psr_mode reg_mode;
	alu_op data_op;

	core_cycles cycles
	(
		.branch(explicit_branch),
		.*
	);

	psr_flags flags, next_flags;

	core_psr psr
	(
		.*
	);

	logic wr_pc;
	word wr_value, rd_value_a, rd_value_b;

	core_regs regs
	(
		.rd_r_a(0), //TODO
		.rd_r_b(0), //TODO
		.rd_mode(reg_mode),
		.wr_mode(reg_mode),
		.wr_r(rd),
		.wr_enable(writeback),
		.branch(wr_pc),
		.*
	);

	psr_flags alu_flags;
	logic alu_v_valid;

	core_alu #(.W(32)) alu
	(
		.op(data_op),
		.a(rd_value_a),
		.b(rd_value_b),
		.c_in(flags.c),
		.q(wr_value),
		.nzcv(alu_flags),
		.v_valid(alu_v_valid)
	);

endmodule
