`include "core/mmu/format.sv"
`include "core/uarch.sv"

module arm810
(
	input  logic      clk,
	                  rst_n,

	input  logic      irq,
	                  halt,
	                  step,

	output ptr        bus_addr,
	output logic      bus_start,
	                  bus_write,
	input  logic      bus_ready,
	input  word       bus_data_rd,
	output word       bus_data_wr,
	output logic[3:0] bus_data_be,

	output logic      halted,
	                  breakpoint
);

	ptr fetch_insn_pc, fetch_head, insn_addr;
	word fetch_insn;
	logic fetch_nop, fetch_abort, stall, flush, prefetch_flush, insn_start;

	//TODO
	assign prefetch_flush = halt;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.nop(fetch_nop),
		.addr(insn_addr),
		.insn(fetch_insn),
		.fetch(insn_start),
		.fault(insn_fault),
		.fetched(insn_ready),
		.insn_pc(fetch_insn_pc),
		.insn_abort(fetch_abort),
		.fetch_data(insn_data_rd),
		.porch_insn_pc(insn_pc),
		.*
	);

	insn_decode fetch_dec;

	core_decode decode
	(
		.dec(fetch_dec),
		.insn(fetch_insn)
	);

	ptr insn_pc;
	word insn;
	logic issue_abort;
	insn_decode dec;

	core_porch porch
	(
		.abort(issue_abort),
		.*
	);

	reg_num rd, ra, rb;
	logic explicit_branch, writeback, c_in;
	ptr branch_target, pc_visible;
	psr_mode reg_mode;
	alu_op alu_ctrl;
	shifter_control shifter_ctrl;
	word alu_a, alu_b, wr_value;
	logic[7:0] shifter_shift;

	core_control control
	(
		.branch(explicit_branch),
		.alu(alu_ctrl),
		.shifter(shifter_ctrl),
		.mem_addr(data_addr),
		.mem_start(data_start),
		.mem_write(data_write),
		.mem_ready(data_ready),
		.mem_fault(data_fault),
		.mem_data_rd(data_data_rd),
		.mem_data_wr(data_data_wr),
		.mem_data_be(data_data_be),
		.*
	);

	word cpsr_rd, spsr_rd, psr_wr;
	psr_mode mode;
	psr_flags flags;
	psr_intmask intmask;

	logic psr_write, psr_saved, update_flags, psr_wr_flags,
	      psr_wr_control, privileged, escalating;

	core_psr psr
	(
		.mask(intmask),
		.write(psr_write),
		.saved(psr_saved),
		.wr_flags(psr_wr_flags),
		.wr_control(psr_wr_control),
		.*
	);

	logic wr_pc;
	word rd_value_a, rd_value_b, wr_current;

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
	word q_alu;

	core_alu #(.W(32)) alu
	(
		.op(alu_ctrl),
		.a(alu_a),
		.b(alu_b),
		.q(q_alu),
		.nzcv(alu_flags),
		.v_valid(alu_v_valid),
		.*
	);

	word shifter_base, q_shifter;
	logic c_shifter;

	core_shifter #(.W(32)) shifter
	(
		.ctrl(shifter_ctrl),
		.base(shifter_base),
		.shift(shifter_shift),
		.c_in(flags.c),
		.q(q_shifter),
		.c(c_shifter)
	);

	logic mul_start, mul_add, mul_long, mul_signed, mul_ready;
	word mul_a, mul_b, mul_c_hi, mul_c_lo, mul_q_hi, mul_q_lo;
	psr_flags mul_flags;

	core_mul mult
	(
		.a(mul_a),
		.b(mul_b),
		.c_hi(mul_c_hi),
		.c_lo(mul_c_lo),
		.long_mul(mul_long),
		.add(mul_add),
		.sig(mul_signed),
		.start(mul_start),
		.q_hi(mul_q_hi),
		.q_lo(mul_q_lo),
		.n(mul_flags.n),
		.z(mul_flags.z),
		.ready(mul_ready),
		.*
	);

	ptr data_addr;
	word data_data_rd, data_data_wr, insn_data_rd;
	logic data_start, data_write, data_ready, insn_ready, data_fault, insn_fault;
	logic[3:0] data_data_be;

	core_mmu mmu
	(
		.*
	);

	ptr fault_addr;
	word coproc_read, mmu_dac;
	logic coproc, high_vectors, mmu_enable, fault_register, fault_page;
	mmu_base mmu_ttbr;
	mmu_domain fault_domain;
	coproc_decode coproc_ctrl;
	mmu_fault_type fault_type;

	core_cp15 cp15
	(
		.transfer(coproc),
		.dec(coproc_ctrl),
		.read(coproc_read),
		.write(rd_value_a),
		.*
	);

endmodule
