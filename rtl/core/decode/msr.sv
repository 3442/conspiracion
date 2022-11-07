`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_decode_msr
(
	input  word     insn,

	output msr_mask fields,
	output logic    spsr,
	                snd_is_imm
);

	assign spsr = insn `FIELD_MSR_R;
	assign fields = insn `FIELD_MSR_MASK;
	assign snd_is_imm = insn `FIELD_MSR_I;

endmodule
