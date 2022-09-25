`include "core/isa.sv"

module core_decode_branch
(
	input  logic[31:0] insn,
	output logic       link,
	output logic[29:0] offset
);

	logic[23:0] immediate;
	assign immediate = insn `FIELD_B_OFFSET;

	assign link = insn `FIELD_B_L;
	assign offset = {{6{immediate[23]}}, immediate};

endmodule
