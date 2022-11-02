`include "core/uarch.sv"
`include "core/cp15/map.sv"

module core_cp15_cpuid
(
	output word read
);

	/* If an <opcode2> value corresponding to an unimplemented or
	 * reserved ID register is encountered, the System Control
	 * coprocessor returns the value of the main ID register.
	 *
	 * ARM810.pdf, p. 104: Reading from CP15 register 0 returns
	 * the value 0x4101810x.
	 */
	assign read = 32'h41018100;

endmodule
