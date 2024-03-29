`include "core/mmu_format.sv"
`include "core/uarch.sv"

module arm810
(
	input  logic      clk,
	                  rst_n,

	input  logic      irq,
	                  halt /*verilator public*/ /*verilator forceable*/,
	                  step /*verilator public*/ /*verilator forceable*/,

	output ptr        bus_addr,
	output logic      bus_start,
	                  bus_write,
	                  bus_ex_lock,
	input  logic      bus_ready,
	                  bus_ex_fail,
	input  word       bus_data_rd,
	output word       bus_data_wr,
	output logic[3:0] bus_data_be,

	output logic      halted /*verilator public*/,
	                  breakpoint /*verilator public*/
);

	ptr branch_target, fetch_insn_pc, fetch_head, insn_addr;
	word fetch_insn;
	logic explicit_branch, fetch_nop, fetch_abort, stall, flush, prefetch_flush;

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

	core_control control
	(
		.alu(alu_ctrl),
		.branch(explicit_branch),
		.shifter(shifter_ctrl),
		.mem_addr(data_addr),
		.mem_user(data_user),
		.mem_start(data_start),
		.mem_write(data_write),
		.mem_ready(data_ready),
		.mem_fault(data_fault),
		.mem_ex_lock(data_ex_lock),
		.mem_ex_fail(data_ex_fail),
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

	ptr pc_visible;
	word rd_value_a, rd_value_b, wr_current, wr_value;
	logic wr_pc, writeback;
	reg_num rd, ra, rb;
	psr_mode rd_mode, wr_mode;

	core_regs regs
	(
		.rd_r_a(ra),
		.rd_r_b(rb),
		.wr_r(rd),
		.wr_enable(writeback),
		.branch(wr_pc),
		.*
	);

	word alu_a, alu_b, q_alu;
	logic c_logic, alu_v_valid;
	alu_op alu_ctrl;
	psr_flags alu_flags;

	core_alu #(.W(32)) alu
	(
		.op(alu_ctrl),
		.a(alu_a),
		.b(alu_b),
		.q(q_alu),
		.c_in(flags.c),
		.nzcv(alu_flags),
		.v_valid(alu_v_valid),
		.*
	);

	word shifter_base, q_shifter;
	logic c_shifter;
	logic[7:0] shifter_shift;
	shifter_control shifter_ctrl;

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
	logic[3:0] data_data_be;

	logic data_start, insn_start, data_write, data_ready, insn_ready,
	      data_fault, insn_fault, data_user, data_ex_lock, data_ex_fail;

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
