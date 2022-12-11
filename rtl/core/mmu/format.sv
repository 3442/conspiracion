`ifndef CORE_MMU_FORMAT_SV
`define CORE_MMU_FORMAT_SV

typedef logic[17:0] mmu_base;
typedef logic[3:0]  mmu_domain;

`define MMU_L1_INDEX     [29:18]
`define MMU_L1_FAULT     2'b00
`define MMU_L1_PAGETABLE 2'b01
`define MMU_L1_SECTION   2'b10

typedef struct packed
{
	logic[31:10] field10;
	logic[9:9]   imp;
	logic[8:5]   domain;
	logic[4:4]   sbz;
	logic[3:2]   field2;
	logic[1:0]   typ;
} mmu_l1_entry;

typedef struct packed
{
	logic[31:10] base;
	logic[9:9]   imp;
	logic[8:5]   domain;
	logic[4:2]   sbz;
	logic[1:0]   typ;
} mmu_l1_pagetable;

typedef struct packed
{
	logic[31:20] base;
	logic[19:15] sbz0;
	logic[14:12] tex;
	logic[11:10] ap;
	logic[9:9]   imp;
	logic[8:5]   domain;
	logic[4:4]   sbz1;
	logic[3:3]   c;
	logic[2:2]   b;
	logic[1:0]   typ;
} mmu_l1_section;

`define MMU_SECTION_INDEX [17:0]

`define MMU_L2_INDEX    [17:10]
`define MMU_L2_FAULT    2'b00
`define MMU_L2_LARGE    2'b01
`define MMU_L2_SMALL    2'b10
`define MMU_L2_SMALLEXT 2'b11

typedef struct packed
{
	logic[31:16] base;
	logic[15:15] sbz;
	logic[14:12] tex;
	logic[11:10] ap3;
	logic[9:8]   ap2;
	logic[7:6]   ap1;
	logic[5:4]   ap0;
	logic[3:3]   c;
	logic[2:2]   b;
	logic[1:0]   typ;
} mmu_l2_large;

typedef struct packed
{
	logic[31:12] base;
	logic[11:10] ap3;
	logic[9:8]   ap2;
	logic[7:6]   ap1;
	logic[5:4]   ap0;
	logic[3:3]   c;
	logic[2:2]   b;
	logic[1:0]   typ;
} mmu_l2_small;

typedef struct packed
{
	logic[31:12] base;
	logic[11:9]  sbz;
	logic[8:6]   tex;
	logic[5:4]   ap;
	logic[3:3]   c;
	logic[2:2]   b;
	logic[1:0]   typ;
} mmu_l2_smallext;

`define MMU_LARGE_INDEX [13:0]
`define MMU_SMALL_INDEX [9:0]

typedef logic[1:0] mmu_fault_type;

`define MMU_FAULT_WALK   2'b01
`define MMU_FAULT_DOMAIN 2'b10
`define MMU_FAULT_ACCESS 2'b11

typedef struct packed
{
	logic manager,
	      allowed;
} mmu_domain_ctrl;

`endif
