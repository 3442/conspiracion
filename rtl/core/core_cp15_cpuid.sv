`include "core/uarch.sv"
`include "core/cp15_map.sv"

module core_cp15_cpuid
(
	input  cp_opcode op2,
	output word      read
);

	/* ARM810.pdf, p. 104: Reading from CP15 register 0 returns
	 * the value 0x4101810x.
	 */
	cp15_cpuid_main main;
	assign main.implementor = 8'h41; // 'A' (ARM)
	assign main.variant = 4'h0;
	assign main.architecture = 4'h1; // ARMv4 (no Thumb)
	assign main.part_number = 12'h810;
	assign main.revision = 4'h0;

	cp15_cpuid_cache cache;
	assign cache.mbz = 3'b000;
	assign cache.ctype = 4'b0001; // Write-back, range ops not supported
	assign cache.s = 1;           // Split instruction and data caches
	assign cache.dsize = cachesize;
	assign cache.isize = cachesize;

	cp15_cpuid_cache_size cachesize;
	assign cachesize.p = 0;
	assign cachesize.mbz = 0;
	assign cachesize.size = 4'b0100; // 8KiB
	assign cachesize.assoc = 3'b001; // 2-way associative
	assign cachesize.m = 0;
	assign cachesize.len = 2'b10;    // 32-byte cache lines

	cp15_cpuid_tcm tcm;
	assign tcm = 0;

	cp15_cpuid_tlb tlb;
	assign tlb.sbz0 = 8'd0;
	assign tlb.ilsize = 8'd0;
	assign tlb.dlsize = 8'd0;
	assign tlb.sbz1 = 7'd0;
	assign tlb.s = 1;

	cp15_cpuid_mpu mpu;
	assign mpu = 0;

	always_comb
		unique case(op2)
			`CP15_CPUID_CACHE:
				read = cache;

			`CP15_CPUID_TCM:
				read = tcm;

			`CP15_CPUID_TLB:
				read = tlb;

			`CP15_CPUID_MPU:
				read = mpu;

			/* If an <opcode2> value corresponding to an unimplemented or
			 * reserved ID register is encountered, the System Control
			 * coprocessor returns the value of the main ID register.
			 */
			default:
				read = main;
		endcase

endmodule
