`ifndef CORE_UARCH_SV
`define CORE_UARCH_SV

// Decodifica como andeq r0, r0, r0
`define NOP 32'd0

typedef enum logic[1:0]
{
	ALU_ADD,
	ALU_AND,
	ALU_ORR,
	ALU_XOR
} alu_op;

`endif
