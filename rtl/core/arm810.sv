`include "core/uarch.sv"

module arm810
(
	input  logic clk,
	             irq,

	output ptr   bus_addr,
	output logic bus_start,
	             bus_write,
	input  logic bus_ready,
	input  word  bus_data_rd,
	output word  bus_data_wr
);

	logic stall, prefetch_flush, insn_start;
	word insn;
	ptr fetch_insn_pc, insn_addr;

	core_fetch #(.PREFETCH_ORDER(2)) fetch
	(
		.branch(explicit_branch | wr_pc),
		.flush(0), //TODO
		.target(wr_pc ? wr_value[31:2] : branch_target),
		.addr(insn_addr),
		.fetched(insn_ready),
		.fetch_data(insn_data_rd),
		.fetch(insn_start),
		.insn_pc(fetch_insn_pc),
		.*
	);

	datapath_decode dec;
	psr_decode dec_psr;
	branch_decode dec_branch;
	snd_decode dec_snd;
	data_decode dec_data;
	ldst_decode dec_ldst;
	mul_decode dec_mul;
	coproc_decode dec_coproc;

	core_decode decode
	(
		.ctrl(dec),
		.psr_ctrl(dec_psr),
		.branch_ctrl(dec_branch),
		.snd_ctrl(dec_snd),
		.data_ctrl(dec_data),
		.ldst_ctrl(dec_ldst),
		.mul_ctrl(dec_mul),
		.coproc_ctrl(dec_coproc),
		.*
	);

	reg_num rd, ra, rb;
	logic explicit_branch, writeback, update_flags, c_in;
	ptr branch_target, pc_visible;
	psr_mode reg_mode;
	psr_flags wb_alu_flags;
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
		.mem_data_rd(data_data_rd),
		.mem_data_wr(data_data_wr),
		.*
	);

	word psr_rd, psr_wr;
	logic psr_write, psr_saved;
	psr_mode mode;
	psr_flags flags;
	psr_intmask intmask;

	core_psr psr
	(
		.mask(intmask),
		.write(psr_write),
		.saved(psr_saved),
		.alu_flags(wb_alu_flags),
		.*
	);

	logic wr_pc;
	word rd_value_a, rd_value_b;

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

	word q_shifter;
	logic c_shifter;

	core_shifter #(.W(32)) shifter
	(
		.ctrl(shifter_ctrl),
		.base(alu_b),
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
	logic data_start, data_write, data_ready, insn_ready;
	word data_data_rd, data_data_wr, insn_data_rd;

	core_mmu mmu
	(
		.*
	);

	logic coproc;
	word coproc_read, coproc_write;

	core_cp15 cp15
	(
		.transfer(coproc),
		.dec(dec_coproc),
		.read(coproc_read),
		.write(coproc_write),
		.*
	);

endmodule
