`include "core/psr.sv"
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

	logic decode_execute, decode_undefined, decode_writeback, decode_branch;
	ptr decode_branch_offset;
	reg_num decode_rd;
	alu_op decode_data_op;

	core_decode decode
	(
		.flags(next_flags),
		.execute(decode_execute),
		.undefined(decode_undefined),
		.writeback(decode_writeback),
		.rd(decode_rd),
		.branch(decode_branch),
		.branch_offset(decode_branch_offset),
		.data_op(decode_data_op),
		.*
	);

	reg_num rd;
	logic explicit_branch, writeback;
	ptr branch_target;
	psr_mode reg_mode;
	alu_op data_op;
	psr_flags flags, next_flags;

	core_cycles cycles
	(
		.branch(explicit_branch),
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

	core_alu #(.W(32)) alu
	(
		.op(data_op),
		.a(rd_value_a),
		.b(rd_value_b),
		.c_in(flags.c),
		.q(wr_value),
		.nzcv(alu_flags),
		.v_valid() //TODO
	);

endmodule
