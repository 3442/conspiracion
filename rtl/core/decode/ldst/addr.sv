`include "core/uarch.sv"

module core_decode_ldst_addr
(
	input  ldst_decode ldst,

	output data_decode alu
);

	assign alu.op = ldst.increment ? `ALU_ADD : `ALU_SUB;
	assign alu.rn = ldst.rn;
	assign alu.rd = ldst.rd;
	assign alu.uses_rn = 1;

endmodule
