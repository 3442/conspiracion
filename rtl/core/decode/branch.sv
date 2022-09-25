`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_branch
(
	input  word  insn,

	output logic link,
	output ptr   offset
);

	logic[23:0] immediate;
	assign immediate = insn `FIELD_B_OFFSET;

	assign link = insn `FIELD_B_L;
	assign offset = {{6{immediate[23]}}, immediate};

endmodule
