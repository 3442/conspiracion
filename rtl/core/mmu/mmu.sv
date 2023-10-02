`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_mmu
(
	input  logic          clk,
	                      rst_n,

	input  logic          privileged,
	                      mmu_enable /*verilator public*/,
	input  mmu_base       mmu_ttbr /*verilator public*/,
	input  word           mmu_dac,

	input  logic          bus_ready,
	                      bus_ex_fail,
	input  word           bus_data_rd,
	                      data_data_wr,
	input  ptr            insn_addr,
	                      data_addr,
	input  logic          insn_start,
	                      data_start,
	                      data_write,
	                      data_ex_lock,
	                      data_user,
	input  logic[3:0]     data_data_be,

	output word           bus_data_wr,
	output logic[3:0]     bus_data_be,
	output ptr            bus_addr,
	output logic          bus_start,
	                      bus_write,
	                      bus_ex_lock,
	                      insn_ready,
	                      insn_fault,
	                      data_ready,
	                      data_fault,
	                      data_ex_fail,
	output word           insn_data_rd,
	                      data_data_rd,

	output logic          fault_register,
	                      fault_page,
	output ptr            fault_addr,
	output mmu_fault_type fault_type,
	output mmu_domain     fault_domain
);

	ptr iphys_addr, dphys_addr;
	word iphys_data_rd, dphys_data_rd, dphys_data_wr;
	logic[3:0] dphys_data_be;

	logic iphys_start, dphys_start, iphys_ready, dphys_ready, dphys_write,
	      dphys_ex_fail, dphys_ex_lock;

	assign fault_register = data_fault;

	core_mmu_pagewalk iwalk
	(
		.core_addr(insn_addr),
		.core_start(insn_start),
		.core_write(0),
		.core_ready(insn_ready),
		.core_data_wr(0),
		.core_data_be(0),
		.core_data_rd(insn_data_rd),
		.core_ex_fail(),
		.core_ex_lock(0),

		.core_fault(insn_fault),
		.core_fault_addr(),
		.core_fault_page(),
		.core_fault_type(),
		.core_fault_domain(),

		.bus_addr(iphys_addr),
		.bus_start(iphys_start),
		.bus_write(),
		.bus_ready(iphys_ready),
		.bus_data_wr(),
		.bus_data_be(),
		.bus_data_rd(iphys_data_rd),
		.bus_ex_fail(0),
		.bus_ex_lock(),

		.*
	);

	core_mmu_pagewalk dwalk
	(
		.core_addr(data_addr),
		.core_start(data_start),
		.core_write(data_write),
		.core_ready(data_ready),
		.core_data_wr(data_data_wr),
		.core_data_be(data_data_be),
		.core_data_rd(data_data_rd),
		.core_ex_fail(data_ex_fail),
		.core_ex_lock(data_ex_lock),

		.core_fault(data_fault),
		.core_fault_addr(fault_addr),
		.core_fault_page(fault_page),
		.core_fault_type(fault_type),
		.core_fault_domain(fault_domain),

		.bus_addr(dphys_addr),
		.bus_start(dphys_start),
		.bus_write(dphys_write),
		.bus_ready(dphys_ready),
		.bus_data_wr(dphys_data_wr),
		.bus_data_be(dphys_data_be),
		.bus_data_rd(dphys_data_rd),
		.bus_ex_fail(dphys_ex_fail),
		.bus_ex_lock(dphys_ex_lock),

		.privileged(privileged && !data_user),
		.*
	);

	core_mmu_arbiter arbiter
	(
		.insn_addr(iphys_addr),
		.insn_start(iphys_start),
		.insn_ready(iphys_ready),
		.insn_data_rd(iphys_data_rd),

		.data_addr(dphys_addr),
		.data_start(dphys_start),
		.data_write(dphys_write),
		.data_ready(dphys_ready),
		.data_data_wr(dphys_data_wr),
		.data_data_be(dphys_data_be),
		.data_data_rd(dphys_data_rd),
		.data_ex_fail(dphys_ex_fail),
		.data_ex_lock(dphys_ex_lock),

		.*
	);

endmodule
