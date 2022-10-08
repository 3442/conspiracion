`ifndef CORE_UARCH_SV
`define CORE_UARCH_SV

// Decodifica como andeq r0, r0, r0
`define NOP 32'd0

typedef logic[3:0]  reg_num;
typedef logic[31:0] word;
typedef logic[29:0] ptr;

`define R14 4'b1110
`define R15 4'b1111

/* Se necesitan 30 GPRs. De A2.3:
 *
 *   The ARM processor has a total of 37 registers:
 *
 *    Thirty-one general-purpose registers, including a program counter. These
 *    registers are 32 bits wide and are described in General-purpose registers on
 *    page A2-6.
 */
typedef logic[4:0] reg_index;

typedef logic[3:0] alu_op;

// Coincide con campo respectivo de instrucciones de procesamiento de datos
`define ALU_AND 4'b0000
`define ALU_EOR 4'b0001
`define ALU_SUB 4'b0010
`define ALU_RSB 4'b0011
`define ALU_ADD 4'b0100
`define ALU_ADC 4'b0101
`define ALU_SBC 4'b0110
`define ALU_RSC 4'b0111
`define ALU_TST 4'b1000
`define ALU_TEQ 4'b1001
`define ALU_CMP 4'b1010
`define ALU_CMN 4'b1011
`define ALU_ORR 4'b1100
`define ALU_MOV 4'b1101
`define ALU_BIC 4'b1110
`define ALU_MVN 4'b1111

typedef struct packed
{
	logic n, z, c, v;
} psr_flags;

typedef logic[4:0] psr_mode;

`define MODE_USR 5'b10000
`define MODE_FIQ 5'b10001
`define MODE_IRQ 5'b10010
`define MODE_SVC 5'b10011
`define MODE_ABT 5'b10111
`define MODE_UND 5'b11011
`define MODE_SYS 5'b11111

typedef struct packed
{
	alu_op  op;
	reg_num rn,
	        rd;
} data_decode;

typedef struct packed
{
	reg_num     r,
	            r_shift;
	logic       shift_by_reg,
	            is_imm,
	            shl,
	            shr,
	            ror,
	            put_carry,
	            sign_extend;
	logic[11:0] imm;
	logic[5:0]  shift_imm;
} snd_decode;

typedef enum logic[1:0]
{
	LDST_WORD,
	LDST_BYTE,
	LDST_HALF
} ldst_size;

typedef struct packed
{
	reg_num     rn,
	            rd;

	logic       enable,
	            load,
	            increment,
	            writeback,
	            sign_extend,
	            pre_indexed,
	            unprivileged,
	            user_regs;

	ldst_size   size;

	/* P. 482: "If no bits are set, the result is UNPREDICTABLE."
	 * Esto permite diferenciar entre ldst múltiple y simple.
	 */
	logic[15:0] reg_list;
} ldst_decode;

typedef struct packed
{
	logic shl,
	      shr,
	      ror,
	      put_carry,
	      sign_extend;
} shifter_control;

`endif
