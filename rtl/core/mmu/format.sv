`ifndef CORE_MMU_FORMAT_SV
`define CORE_MMU_FORMAT_SV

typedef logic[17:0] mmu_base;

`define MMU_L1_INDEX     [29:18]
`define MMU_L1_FAULT     2'b00
`define MMU_L1_PAGETABLE 2'b01
`define MMU_L1_SECTION   2'b10

`define MMU_L2_INDEX    [17:10]
`define MMU_L2_FAULT    2'b00
`define MMU_L2_LARGE    2'b01
`define MMU_L2_SMALL    2'b10
`define MMU_L2_SMALLEXT 2'b11

`define MMU_LARGE_INDEX [13:0]
`define MMU_SMALL_INDEX [11:0]

`endif
