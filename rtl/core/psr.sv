`ifndef CORE_PSR_SV
`define CORE_PSR_SV

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

`endif
