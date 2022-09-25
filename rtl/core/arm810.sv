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

	psr_flags flags;
	assign flags = 4'b1010; //TODO

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

	core_decode decode
	(
		.execute(decode_execute),
		.undefined(decode_undefined),
		.writeback(decode_writeback),
		.rd(decode_rd),
		.branch(decode_branch),
		.branch_offset(decode_branch_offset),
		.*
	);

	reg_num rd;
	logic explicit_branch, writeback;
	ptr branch_target;
	psr_mode reg_mode;

	core_cycles cycles
	(
		.branch(explicit_branch),
		.*
	);

	logic wr_pc;
	word wr_value;

	core_regs regs
	(
		.rd_r_a(0), //TODO
		.rd_r_b(0), //TODO
		.rd_value_a(), //TODO
		.rd_value_b(), //TODO
		.rd_mode(reg_mode),
		.wr_mode(reg_mode),
		.wr_r(rd),
		.wr_enable(writeback),
		.branch(wr_pc),
		.*
	);

endmodule
