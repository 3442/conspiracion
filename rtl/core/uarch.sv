`ifndef CORE_UARCH_SV
`define CORE_UARCH_SV

// Decodifica como andeq r0, r0, r0
`define NOP 32'd0

typedef logic[31:0] word;
typedef logic[29:0] ptr;

/* Se necesitan 30 GPRs. De A2.3:
 *
 *   The ARM processor has a total of 37 registers:
 *
 *    Thirty-one general-purpose registers, including a program counter. These
 *    registers are 32 bits wide and are described in General-purpose registers on
 *    page A2-6.
 */
typedef logic[4:0] reg_index;

typedef enum logic[1:0]
{
	ALU_ADD,
	ALU_AND,
	ALU_ORR,
	ALU_XOR
} alu_op;

`endif
