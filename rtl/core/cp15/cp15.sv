`include "core/cp15/map.sv"
`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_cp15
(
	input  logic          clk,
	                      rst_n,
	                      transfer,
	input  coproc_decode  dec,
	input  word           write,

	input  logic          fault_register,
	                      fault_page,
	input  ptr            fault_addr,
	input  mmu_fault_type fault_type,
	input  mmu_domain     fault_domain,

	output word           read,
	                      mmu_dac,
	output logic          high_vectors,
	                      mmu_enable,
	output mmu_base       mmu_ttbr
);

	logic load;
	reg_num crn, crm;
	cp_opcode op1, op2;

	assign {crn, crm} = {dec.crn, dec.crm};
	assign {op1, op2} = {dec.op1, dec.op2};
	assign load = dec.load;

	word read_cpuid, read_syscfg, read_ttbr, read_domain,
	     read_far, read_fsr, read_cache_lockdown, read_tlb_lockdown;

	core_cp15_cpuid cpuid
	(
		.read(read_cpuid),
		.*
	);

	core_cp15_syscfg syscfg
	(
		.read(read_syscfg),
		.transfer(transfer && crn == `CP15_CRN_SYSCFG),
		.*
	);

	core_cp15_ttbr ttbr
	(
		.read(read_ttbr),
		.transfer(transfer && crn == `CP15_CRN_TTBR),
		.*
	);

	core_cp15_domain domain
	(
		.read(read_domain),
		.transfer(transfer && crn == `CP15_CRN_DOMAIN),
		.*
	);

	core_cp15_far far
	(
		.read(read_far),
		.transfer(transfer && crn == `CP15_CRN_FAR),
		.*
	);

	core_cp15_fsr fsr
	(
		.read(read_fsr),
		.transfer(transfer && crn == `CP15_CRN_FSR),
		.*
	);

	core_cp15_cache cache
	(
		.transfer(transfer && crn == `CP15_CRN_CACHE),
		.*
	);

	core_cp15_tlb tlb
	(
		.transfer(transfer && crn == `CP15_CRN_TLB),
		.*
	);

	core_cp15_cache_lockdown cache_lockdown
	(
		.read(read_cache_lockdown),
		.transfer(transfer && crn == `CP15_CRN_CACHE_LCK),
		.*
	);

	core_cp15_tlb_lockdown tlb_lockdown
	(
		.read(read_tlb_lockdown),
		.transfer(transfer && crn == `CP15_CRN_TLB_LCK),
		.*
	);

	always_comb
		unique case(crn)
			`CP15_CRN_CPUID:
				read = read_cpuid;

			`CP15_CRN_SYSCFG:
				read = read_syscfg;

			`CP15_CRN_TTBR:
				read = read_ttbr;

			`CP15_CRN_DOMAIN:
				read = read_domain;

			`CP15_CRN_FAR:
				read = read_far;

			`CP15_CRN_FSR:
				read = read_fsr;

			`CP15_CRN_CACHE_LCK:
				read = read_cache_lockdown;

			`CP15_CRN_TLB_LCK:
				read = read_tlb_lockdown;

			default:
				read = {$bits(read){1'bx}};
		endcase

endmodule
