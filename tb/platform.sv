


module platform
(
	input  wire        clk_clk,                          //                       clk.clk
	input  wire [29:0] master_0_core_addr    /*verilator public*/,// master_0_core.addr
	output wire [31:0] master_0_core_data_rd /*verilator public*/,//              .data_rd
	input  wire [31:0] master_0_core_data_wr /*verilator public*/,//              .data_wr
	output wire        master_0_core_ready   /*verilator public*/,//              .ready
	input  wire        master_0_core_write   /*verilator public*/,//              .write
	input  wire        master_0_core_start   /*verilator public*/,//              .start
	output wire        master_0_core_irq,                //                          .irq
	output wire        master_0_core_cpu_clk,            //                          .cpu_clk
	output wire [12:0] memory_mem_a,                     //                    memory.mem_a
	output wire [2:0]  memory_mem_ba,                    //                          .mem_ba
	output wire        memory_mem_ck,                    //                          .mem_ck
	output wire        memory_mem_ck_n,                  //                          .mem_ck_n
	output wire        memory_mem_cke,                   //                          .mem_cke
	output wire        memory_mem_cs_n,                  //                          .mem_cs_n
	output wire        memory_mem_ras_n,                 //                          .mem_ras_n
	output wire        memory_mem_cas_n,                 //                          .mem_cas_n
	output wire        memory_mem_we_n,                  //                          .mem_we_n
	output wire        memory_mem_reset_n,               //                          .mem_reset_n
	inout  wire [7:0]  memory_mem_dq,                    //                          .mem_dq
	inout  wire        memory_mem_dqs,                   //                          .mem_dqs
	inout  wire        memory_mem_dqs_n,                 //                          .mem_dqs_n
	output wire        memory_mem_odt,                   //                          .mem_odt
	output wire        memory_mem_dm,                    //                          .mem_dm
	input  wire        memory_oct_rzqin,                 //                          .oct_rzqin
	output wire [7:0]  pio_0_external_connection_export, // pio_0_external_connection.export
	output wire        pll_0_outclk3_clk,                //             pll_0_outclk3.clk
	input  wire        reset_reset_n,                    //                     reset.reset_n
	output wire [12:0] vram_wire_addr,                   //                 vram_wire.addr
	output wire [1:0]  vram_wire_ba,                     //                          .ba
	output wire        vram_wire_cas_n,                  //                          .cas_n
	output wire        vram_wire_cke,                    //                          .cke
	output wire        vram_wire_cs_n,                   //                          .cs_n
	inout  wire [15:0] vram_wire_dq,                     //                          .dq
	output wire [1:0]  vram_wire_dqm,                    //                          .dqm
	output wire        vram_wire_ras_n,                  //                          .ras_n
	output wire        vram_wire_we_n,                   //                          .we_n
	output wire        vga_controller_0_dac_clk,         //      vga_controller_0_dac.clk
	output wire        vga_controller_0_dac_hsync,       //                          .hsync
	output wire        vga_controller_0_dac_vsync,       //                          .vsync
	output wire        vga_controller_0_dac_blank_n,     //                          .blank_n
	output wire        vga_controller_0_dac_sync_n,      //                          .sync_n
	output wire [7:0]  vga_controller_0_dac_r,           //                          .r
	output wire [7:0]  vga_controller_0_dac_g,           //                          .g
	output wire [7:0]  vga_controller_0_dac_b            //                          .b
);

	logic[31:0] avl_address /*verilator public*/;
	logic       avl_read /*verilator public*/;
	logic       avl_write /*verilator public*/;
	logic       avl_irq /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_writedata /*verilator public*/;
	logic       avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[3:0]  avl_byteenable /*verilator public*/;

	bus_master master_0
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.addr(master_0_core_addr),
		.start(master_0_core_start),
		.write(master_0_core_write),
		.ready(master_0_core_ready),
		.data_rd(master_0_core_data_rd),
		.data_wr(master_0_core_data_wr),
		.cpu_clk(master_0_core_cpu_clk),
		.irq(master_0_core_irq),
		.*
	);

endmodule
