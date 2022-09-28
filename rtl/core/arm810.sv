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
		.branch(explicit_branch | wr_pc),
		.flush(0), //TODO
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
	alu_decode dec_alu;

	core_decode decode
	(
		.execute(dec_execute),
		.undefined(dec_undefined),
		.writeback(dec_writeback),
		.branch(dec_branch),
		.update_flags(dec_update_flags),
		.branch_offset(dec_branch_offset),
		.alu(dec_alu),
		.*
	);

	reg_num rd, ra, rb;
	logic explicit_branch, writeback, update_flags;
	ptr branch_target;
	psr_mode reg_mode;
	alu_control alu_ctrl;
	word alu_base;
	logic[7:0] alu_shift;

	core_cycles cycles
	(
		.branch(explicit_branch),
		.alu(alu_ctrl),
		.*
	);

	psr_flags flags;

	core_psr psr
	(
		.*
	);

	logic wr_pc;
	word wr_value, rd_value_a, rd_value_b;

	core_regs regs
	(
		.rd_r_a(ra),
		.rd_r_b(rb),
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
		.ctrl(alu_ctrl),
		.a(rd_value_a),
		.base(alu_base),
		.shift(alu_shift),
		.c_in(flags.c),
		.q(wr_value),
		.nzcv(alu_flags),
		.v_valid(alu_v_valid)
	);

endmodule
