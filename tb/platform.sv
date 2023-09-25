`include "cache/defs.sv"

module platform
(
	input  wire        clk_clk,                          //                       clk.clk
	input  wire [29:0] master_0_core_addr,               // master_0_core.addr
	output wire [31:0] master_0_core_data_rd,            //              .data_rd
	input  wire [31:0] master_0_core_data_wr,            //              .data_wr
	input  wire [3:0]  master_0_core_data_be,            //              .data_be
	output wire        master_0_core_ready,              //              .ready
	input  wire        master_0_core_write,              //              .write
	input  wire        master_0_core_start,              //              .start
	output wire        master_0_core_irq,                //                          .irq
	output wire        master_0_core_cpu_clk,            //                          .cpu_clk
	output wire        master_0_core_cpu_rst_n,
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
	input  wire [7:0]  switches_external_connection_export, // pio_1_external_connection.export
	input  wire [7:0]  buttons_external_connection_export, // pio_2_external_connection.export
	input  wire        pll_0_reset_reset,
	output wire        sys_sdram_pll_0_sdram_clk_clk,
	input  wire        reset_reset_n /*verilator public*/,//                     reset.reset_n
	output wire [12:0] vram_wire_addr,                   //                 vram_wire.addr
	output wire [1:0]  vram_wire_ba,                     //                          .ba
	output wire        vram_wire_cas_n,                  //                          .cas_n
	output wire        vram_wire_cke,                    //                          .cke
	output wire        vram_wire_cs_n,                   //                          .cs_n
	inout  wire [15:0] vram_wire_dq,                     //                          .dq
	output wire [1:0]  vram_wire_dqm,                    //                          .dqm
	output wire        vram_wire_ras_n,                  //                          .ras_n
	output wire        vram_wire_we_n,                   //                          .we_n
	output wire        vga_dac_CLK,                      //                   vga_dac.CLK
	output wire        vga_dac_HS,                       //                          .HS
	output wire        vga_dac_VS,                       //                          .VS
	output wire        vga_dac_BLANK,                    //                          .BLANK
	output wire        vga_dac_SYNC,                     //                          .SYNC
	output wire [7:0]  vga_dac_R,                        //                          .R
	output wire [7:0]  vga_dac_G,                        //                          .G
	output wire [7:0]  vga_dac_B                        //                          .B
);

	logic[31:0]  avl_address /*verilator public*/;
	logic        avl_read /*verilator public*/;
	logic        avl_write /*verilator public*/;
	logic        avl_irq /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[127:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[127:0] avl_writedata /*verilator public*/;
	logic        avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[15:0]  avl_byteenable /*verilator public*/;

	logic[31:0] core_avl_address;
	logic       core_avl_read;
	logic       core_avl_write;
	logic[31:0] core_avl_readdata;
	logic[31:0] core_avl_writedata;
	logic       core_avl_waitrequest;
	logic[3:0]  core_avl_byteenable;

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
		.data_be(master_0_core_data_be),
		.cpu_clk(master_0_core_cpu_clk),
		.cpu_rst_n(master_0_core_cpu_rst_n),
		.irq(master_0_core_irq),
		.avl_address(core_avl_address),
		.avl_read(core_avl_read),
		.avl_write(core_avl_write),
		.avl_readdata(core_avl_readdata),
		.avl_writedata(core_avl_writedata),
		.avl_waitrequest(core_avl_waitrequest),
		.avl_byteenable(core_avl_byteenable),
		.*
	);

	vga_domain vga
	(
		.*
	);

	ring_req data_0, data_1, data_2, data_3;
	ring_token token_0, token_1, token_2, token_3;

	logic data_valid_0, data_valid_1, data_valid_2, data_valid_3,
	      data_ready_0, data_ready_1, data_ready_2, data_ready_3,
	      token_valid_0, token_valid_1, token_valid_2, token_valid_3;

	cache #(.TOKEN_AT_RESET(0)) c0
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.core_address(core_avl_address[31:2]),
		.core_read(core_avl_read),
		.core_write(core_avl_write),
		.core_writedata(core_avl_writedata),
		.core_byteenable(core_avl_byteenable),
		.core_waitrequest(core_avl_waitrequest),
		.core_readdata(core_avl_readdata),

		//.dbg_address(),
		.dbg_read(0),
		.dbg_write(0),
		.dbg_writedata(),
		.dbg_waitrequest(),
		.dbg_readdata(),

		.mem_waitrequest(avl_waitrequest),
		.mem_readdata(avl_readdata),
		.mem_address(avl_address),
		.mem_read(avl_read),
		.mem_write(avl_write),
		.mem_writedata(avl_writedata),
		.mem_byteenable(avl_byteenable),

		.in_data_valid(data_valid_3),
		.in_data(data_3),
		.in_data_ready(data_ready_0),

		.out_data_valid(data_valid_0),
		.out_data(data_0),
		.out_data_ready(data_ready_1),

		.in_token(token_3),
		.in_token_valid(token_valid_3),

		.out_token(token_0),
		.out_token_valid(token_valid_0)
	);

	cache #(.TOKEN_AT_RESET(0)) c1
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.core_address(),
		.core_read(0),
		.core_write(0),
		.core_writedata(),
		.core_byteenable(),
		.core_waitrequest(),
		.core_readdata(),

		//.dbg_address(),
		.dbg_read(0),
		.dbg_write(0),
		.dbg_writedata(),
		.dbg_waitrequest(),
		.dbg_readdata(),

		.mem_waitrequest(1),
		.mem_readdata(),
		.mem_address(),
		.mem_read(),
		.mem_write(),
		.mem_writedata(),
		.mem_byteenable(),

		.in_data_valid(data_valid_0),
		.in_data(data_0),
		.in_data_ready(data_ready_1),

		.out_data_valid(data_valid_1),
		.out_data(data_1),
		.out_data_ready(data_ready_2),

		.in_token(token_0),
		.in_token_valid(token_valid_0),

		.out_token(token_1),
		.out_token_valid(token_valid_1)
	);

	cache #(.TOKEN_AT_RESET(0)) c2
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.core_address(),
		.core_read(0),
		.core_write(0),
		.core_writedata(),
		.core_byteenable(),
		.core_waitrequest(),
		.core_readdata(),

		//.dbg_address(),
		.dbg_read(0),
		.dbg_write(0),
		.dbg_writedata(),
		.dbg_waitrequest(),
		.dbg_readdata(),

		.mem_waitrequest(1),
		.mem_readdata(),
		.mem_address(),
		.mem_read(),
		.mem_write(),
		.mem_writedata(),
		.mem_byteenable(),

		.in_data_valid(data_valid_1),
		.in_data(data_1),
		.in_data_ready(data_ready_2),

		.out_data_valid(data_valid_2),
		.out_data(data_2),
		.out_data_ready(data_ready_3),

		.in_token(token_1),
		.in_token_valid(token_valid_1),

		.out_token(token_2),
		.out_token_valid(token_valid_2)
	);

	cache #(.TOKEN_AT_RESET(1)) c3
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.core_address(),
		.core_read(0),
		.core_write(0),
		.core_writedata(),
		.core_byteenable(),
		.core_waitrequest(),
		.core_readdata(),

		//.dbg_address(),
		.dbg_read(0),
		.dbg_write(0),
		.dbg_writedata(),
		.dbg_waitrequest(),
		.dbg_readdata(),

		.mem_waitrequest(1),
		.mem_readdata(),
		.mem_address(),
		.mem_read(),
		.mem_write(),
		.mem_writedata(),
		.mem_byteenable(),

		.in_data_valid(data_valid_2),
		.in_data(data_2),
		.in_data_ready(data_ready_3),

		.out_data_valid(data_valid_3),
		.out_data(data_3),
		.out_data_ready(data_ready_0),

		.in_token(token_2),
		.in_token_valid(token_valid_2),

		.out_token(token_3),
		.out_token_valid(token_valid_3)
	);

endmodule
