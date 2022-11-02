`include "core/uarch.sv"
`include "core/cp15/map.sv"

module core_cp15
(
	input  logic         clk,
	                     transfer,
	input  coproc_decode dec,
	input  word          write,

	output word          read
);

	logic load;
	reg_num crm;
	cp_opcode op1, op2;

	assign load = dec.load;
	assign crm = dec.crm;
	assign op1 = dec.op1;
	assign op2 = dec.op2;

	word read_cpuid;

	core_cp15_cpuid cpuid
	(
		.read(read_cpuid),
		.*
	);

	always_comb
		unique case(dec.crn)
			`CP15_CRN_CPUID:
				read = read_cpuid;

			default:
				read = {$bits(read){1'bx}};
		endcase

endmodule
