`ifndef CORE_CP15_MAP_SV
`define CORE_CP15_MAP_SV

`define CP15_CRN_CPUID     4'd0
`define CP15_CRN_SYSCFG    4'd1
`define CP15_CRN_TTBR      4'd2
`define CP15_CRN_DOMAIN    4'd3
`define CP15_CRN_FSR       4'd5
`define CP15_CRN_FAR       4'd6
`define CP15_CRN_CACHE     4'd7
`define CP15_CRN_TLB       4'd8
`define CP15_CRN_CACHE_LCK 4'd9
`define CP15_CRN_TLB_LCK   4'd10
`define CP15_CRN_DMA       4'd11
`define CP15_CRN_PID       4'd13
`define CP15_CRN_CYCLECNT  4'd15

typedef struct packed
{
	logic[31:24] implementor;
	logic[23:20] variant;
	logic[19:16] architecture;
	logic[15:4]  part_number;
	logic[3:0]   revision;
} cp15_cpuid_main;

`define CP15_CPUID_CACHE 3'b001

typedef struct packed
{
	logic[11:11] p;
	logic[10:10] mbz;
	logic[9:6]   size;
	logic[5:3]   assoc;
	logic[2:2]   m;
	logic[1:0]   len;
} cp15_cpuid_cache_size;

typedef struct packed
{
	logic[31:29]          mbz;
	logic[28:25]          ctype;
	logic[24:24]          s;
	cp15_cpuid_cache_size dsize,
	                      isize;
} cp15_cpuid_cache;

`define CP15_CPUID_TCM 3'b010

typedef struct packed
{
	logic[31:29] mbz;
	logic[28:19] sbz0;
	logic[18:16] dtcm;
	logic[15:3]  sbz1;
	logic[2:0]   itcm;
} cp15_cpuid_tcm;

`define CP15_CPUID_TLB 3'b011

typedef struct packed
{
	logic[31:24] sbz0;
	logic[23:16] ilsize;
	logic[15:8]  dlsize;
	logic[7:1]   sbz1;
	logic[0:0]   s;
} cp15_cpuid_tlb;

`define CP15_CPUID_MPU 3'b100

typedef struct packed
{
	logic[31:24] sbz0;
	logic[23:16] iregion;
	logic[15:8]  dregion;
	logic[7:1]   sbz1;
	logic[0:0]   s;
} cp15_cpuid_mpu;

`define CP15_SYSCFG_CTRL 3'b000

typedef struct packed
{
	logic[31:27] reserved;
	logic[26:26] l2;
	logic[25:25] ee;
	logic[24:24] ve;
	logic[23:23] xp;
	logic[22:22] u;
	logic[21:21] fi;
	logic[20:20] st;
	logic[19:19] sbz0;
	logic[18:18] it;
	logic[17:17] sbz1;
	logic[16:16] dt;
	logic[15:15] l4;
	logic[14:14] rr;
	logic[13:13] v;
	logic[12:12] i;
	logic[11:11] z;
	logic[10:10] f;
	logic[9:9]   r;
	logic[8:8]   s;
	logic[7:7]   b;
	logic[6:6]   l;
	logic[5:5]   d;
	logic[4:4]   p;
	logic[3:3]   w;
	logic[2:2]   c;
	logic[1:1]   a;
	logic[0:0]   m;
} cp15_syscfg_ctrl;

`define CP15_SYSCFG_ACCESS 3'b010

typedef struct packed
{
	logic[31:14] base;
	logic[13:5]  sbz;
	logic[4:3]   rgn;
	logic[2:2]   imp;
	logic[1:1]   s;
	logic[0:0]   c;
} cp15_ttbr;

`define CP15_PID_FSCE     3'd0
`define CP15_PID_CONTEXT  3'd1
`define CP15_PID_TPIDRURW 3'd2
`define CP15_PID_TDIDRURO 3'd3
`define CP15_PID_TDIDRPRW 3'd4

`endif
