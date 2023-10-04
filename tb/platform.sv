`include "cache/defs.sv"

module platform
(
	input  wire [7:0]  buttons_external_connection_export,  //  buttons_external_connection.export
	input  wire        clk_clk,                             //                          clk.clk
	output wire [12:0] memory_mem_a,                        //                       memory.mem_a
	output wire [2:0]  memory_mem_ba,                       //                             .mem_ba
	output wire        memory_mem_ck,                       //                             .mem_ck
	output wire        memory_mem_ck_n,                     //                             .mem_ck_n
	output wire        memory_mem_cke,                      //                             .mem_cke
	output wire        memory_mem_cs_n,                     //                             .mem_cs_n
	output wire        memory_mem_ras_n,                    //                             .mem_ras_n
	output wire        memory_mem_cas_n,                    //                             .mem_cas_n
	output wire        memory_mem_we_n,                     //                             .mem_we_n
	output wire        memory_mem_reset_n,                  //                             .mem_reset_n
	inout  wire [7:0]  memory_mem_dq,                       //                             .mem_dq
	inout  wire        memory_mem_dqs,                      //                             .mem_dqs
	inout  wire        memory_mem_dqs_n,                    //                             .mem_dqs_n
	output wire        memory_mem_odt,                      //                             .mem_odt
	output wire        memory_mem_dm,                       //                             .mem_dm
	input  wire        memory_oct_rzqin,                    //                             .oct_rzqin
	output wire [7:0]  pio_0_external_connection_export,    //    pio_0_external_connection.export
	input  wire        pll_0_reset_reset,                   //                  pll_0_reset.reset
	input  wire        reset_reset_n /*verilator public*/,  //                        reset.reset_n
	input  wire [7:0]  switches_external_connection_export, // switches_external_connection.export
	output wire        sys_sdram_pll_0_sdram_clk_clk,       //    sys_sdram_pll_0_sdram_clk.clk
	output wire        vga_dac_CLK,                         //                      vga_dac.CLK
	output wire        vga_dac_HS,                          //                             .HS
	output wire        vga_dac_VS,                          //                             .VS
	output wire        vga_dac_BLANK,                       //                             .BLANK
	output wire        vga_dac_SYNC,                        //                             .SYNC
	output wire [7:0]  vga_dac_R,                           //                             .R
	output wire [7:0]  vga_dac_G,                           //                             .G
	output wire [7:0]  vga_dac_B,                           //                             .B
	output wire [12:0] vram_wire_addr,                      //                    vram_wire.addr
	output wire [1:0]  vram_wire_ba,                        //                             .ba
	output wire        vram_wire_cas_n,                     //                             .cas_n
	output wire        vram_wire_cke,                       //                             .cke
	output wire        vram_wire_cs_n,                      //                             .cs_n
	inout  wire [15:0] vram_wire_dq,                        //                             .dq
	output wire [1:0]  vram_wire_dqm,                       //                             .dqm
	output wire        vram_wire_ras_n,                     //                             .ras_n
	output wire        vram_wire_we_n                       //                             .we_n
);

	logic clk, rst_n;
	assign clk = clk_clk;
	assign rst_n = reset_reset_n;

	logic[31:0]  avl_address /*verilator public*/;
	logic        avl_read /*verilator public*/;
	logic        avl_write /*verilator public*/;
	logic        avl_irq /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[127:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[127:0] avl_writedata /*verilator public*/;
	logic        avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[15:0]  avl_byteenable /*verilator public*/;

	logic[31:0]  mem_0_address, mem_1_address, mem_2_address, mem_3_address;
	logic        mem_0_read, mem_1_read, mem_2_read, mem_3_read;
	logic        mem_0_write, mem_1_write, mem_2_write, mem_3_write;
	logic[127:0] mem_0_readdata, mem_1_readdata, mem_2_readdata, mem_3_readdata;
	logic[127:0] mem_0_writedata, mem_1_writedata, mem_2_writedata, mem_3_writedata;
	logic        mem_0_waitrequest, mem_1_waitrequest, mem_2_waitrequest, mem_3_waitrequest;
	logic[15:0]  mem_0_byteenable, mem_1_byteenable, mem_2_byteenable, mem_3_byteenable;

	logic[31:0] cpu_0_address, cpu_1_address, cpu_2_address, cpu_3_address,
	            dbg_0_address, dbg_1_address, dbg_2_address, dbg_3_address;
	logic       cpu_0_read, cpu_1_read, cpu_2_read, cpu_3_read,
	            dbg_0_read, dbg_1_read, dbg_2_read, dbg_3_read,
	            cpu_0_write, cpu_1_write, cpu_2_write, cpu_3_write,
	            dbg_0_write, dbg_1_write, dbg_2_write, dbg_3_write,
	            cpu_0_lock, cpu_1_lock, cpu_2_lock, cpu_3_lock;
	logic[31:0] cpu_0_readdata, cpu_1_readdata, cpu_2_readdata, cpu_3_readdata,
	            dbg_0_readdata, dbg_1_readdata, dbg_2_readdata, dbg_3_readdata;
	logic[31:0] cpu_0_writedata, cpu_1_writedata, cpu_2_writedata, cpu_3_writedata,
	            dbg_0_writedata, dbg_1_writedata, dbg_2_writedata, dbg_3_writedata;
	logic       cpu_0_waitrequest, cpu_1_waitrequest, cpu_2_waitrequest, cpu_3_waitrequest,
	            dbg_0_waitrequest, dbg_1_waitrequest, dbg_2_waitrequest, dbg_3_waitrequest;
	logic[1:0]  cpu_0_response, cpu_1_response, cpu_2_response, cpu_3_response;
	logic[3:0]  cpu_0_byteenable, cpu_1_byteenable, cpu_2_byteenable, cpu_3_byteenable;

	core cpu_0
	(
		.step(step_0),
		.breakpoint(breakpoint_0),
		.cpu_halt(halt_0),
		.cpu_halted(cpu_halted_0),
		.avl_address(cpu_0_address),
		.avl_read(cpu_0_read),
		.avl_write(cpu_0_write),
		.avl_lock(cpu_0_lock),
		.avl_readdata(cpu_0_readdata),
		.avl_writedata(cpu_0_writedata),
		.avl_waitrequest(cpu_0_waitrequest),
		.avl_response(cpu_0_response),
		.avl_byteenable(cpu_0_byteenable),
		.*
	);

	core cpu_1
	(
		.step(step_1),
		.breakpoint(breakpoint_1),
		.cpu_halt(halt_1),
		.cpu_halted(cpu_halted_1),
		.avl_address(cpu_1_address),
		.avl_read(cpu_1_read),
		.avl_write(cpu_1_write),
		.avl_lock(cpu_1_lock),
		.avl_readdata(cpu_1_readdata),
		.avl_writedata(cpu_1_writedata),
		.avl_waitrequest(cpu_1_waitrequest),
		.avl_response(cpu_1_response),
		.avl_byteenable(cpu_1_byteenable),
		.avl_irq(0),
		.*
	);

	core cpu_2
	(
		.step(step_2),
		.breakpoint(breakpoint_2),
		.cpu_halt(halt_2),
		.cpu_halted(cpu_halted_2),
		.avl_address(cpu_2_address),
		.avl_read(cpu_2_read),
		.avl_write(cpu_2_write),
		.avl_lock(cpu_2_lock),
		.avl_readdata(cpu_2_readdata),
		.avl_writedata(cpu_2_writedata),
		.avl_waitrequest(cpu_2_waitrequest),
		.avl_response(cpu_2_response),
		.avl_byteenable(cpu_2_byteenable),
		.avl_irq(0),
		.*
	);

	core cpu_3
	(
		.step(step_3),
		.breakpoint(breakpoint_3),
		.cpu_halt(halt_3),
		.cpu_halted(cpu_halted_3),
		.avl_address(cpu_3_address),
		.avl_read(cpu_3_read),
		.avl_write(cpu_3_write),
		.avl_lock(cpu_3_lock),
		.avl_readdata(cpu_3_readdata),
		.avl_writedata(cpu_3_writedata),
		.avl_waitrequest(cpu_3_waitrequest),
		.avl_response(cpu_3_response),
		.avl_byteenable(cpu_3_byteenable),
		.avl_irq(0),
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

	cache cache_0
	(
		.core_address(cpu_0_address[31:2]),
		.core_read(cpu_0_read),
		.core_write(cpu_0_write),
		.core_lock(cpu_0_lock),
		.core_writedata(cpu_0_writedata),
		.core_byteenable(cpu_0_byteenable),
		.core_waitrequest(cpu_0_waitrequest),
		.core_response(cpu_0_response),
		.core_readdata(cpu_0_readdata),

		.mem_waitrequest(mem_0_waitrequest),
		.mem_readdata(mem_0_readdata),
		.mem_address(mem_0_address),
		.mem_read(mem_0_read),
		.mem_write(mem_0_write),
		.mem_writedata(mem_0_writedata),
		.mem_byteenable(mem_0_byteenable),

		.in_data_valid(data_valid_3),
		.in_data(data_3),
		.in_data_ready(data_ready_0),

		.out_data_valid(data_valid_0),
		.out_data(data_0),
		.out_data_ready(data_ready_1),

		.in_token(token_3),
		.in_token_valid(token_valid_3),

		.out_token(token_0),
		.out_token_valid(token_valid_0),

		.dbg_read(dbg_0_read),
		.dbg_write(dbg_0_write),
		.dbg_address(dbg_0_address[2:0]),
		.dbg_readdata(dbg_0_readdata),
		.dbg_writedata(dbg_0_writedata),
		.dbg_waitrequest(dbg_0_waitrequest),

		.*
	);

	sim_slave smp_dbg_0
	(
		.read(dbg_0_read),
		.write(dbg_0_write),
		.address(dbg_0_address),
		.readdata(dbg_0_readdata),
		.writedata(dbg_0_writedata),
		.waitrequest(dbg_0_waitrequest),

		.*
	);

	cache cache_1
	(
		.core_address(cpu_1_address[31:2]),
		.core_read(cpu_1_read),
		.core_write(cpu_1_write),
		.core_lock(cpu_1_lock),
		.core_writedata(cpu_1_writedata),
		.core_byteenable(cpu_1_byteenable),
		.core_waitrequest(cpu_1_waitrequest),
		.core_response(cpu_1_response),
		.core_readdata(cpu_1_readdata),

		.mem_waitrequest(mem_1_waitrequest),
		.mem_readdata(mem_1_readdata),
		.mem_address(mem_1_address),
		.mem_read(mem_1_read),
		.mem_write(mem_1_write),
		.mem_writedata(mem_1_writedata),
		.mem_byteenable(mem_1_byteenable),

		.in_data_valid(data_valid_0),
		.in_data(data_0),
		.in_data_ready(data_ready_1),

		.out_data_valid(data_valid_1),
		.out_data(data_1),
		.out_data_ready(data_ready_2),

		.in_token(token_0),
		.in_token_valid(token_valid_0),

		.out_token(token_1),
		.out_token_valid(token_valid_1),

		.dbg_read(dbg_1_read),
		.dbg_write(dbg_1_write),
		.dbg_address(dbg_1_address[2:0]),
		.dbg_readdata(dbg_1_readdata),
		.dbg_writedata(dbg_1_writedata),
		.dbg_waitrequest(dbg_1_waitrequest),

		.*
	);

	sim_slave smp_dbg_1
	(
		.read(dbg_1_read),
		.write(dbg_1_write),
		.address(dbg_1_address),
		.readdata(dbg_1_readdata),
		.writedata(dbg_1_writedata),
		.waitrequest(dbg_1_waitrequest),

		.*
	);

	cache cache_2
	(
		.core_address(cpu_2_address[31:2]),
		.core_read(cpu_2_read),
		.core_write(cpu_2_write),
		.core_lock(cpu_2_lock),
		.core_writedata(cpu_2_writedata),
		.core_byteenable(cpu_2_byteenable),
		.core_waitrequest(cpu_2_waitrequest),
		.core_response(cpu_2_response),
		.core_readdata(cpu_2_readdata),

		.mem_waitrequest(mem_2_waitrequest),
		.mem_readdata(mem_2_readdata),
		.mem_address(mem_2_address),
		.mem_read(mem_2_read),
		.mem_write(mem_2_write),
		.mem_writedata(mem_2_writedata),
		.mem_byteenable(mem_2_byteenable),

		.in_data_valid(data_valid_1),
		.in_data(data_1),
		.in_data_ready(data_ready_2),

		.out_data_valid(data_valid_2),
		.out_data(data_2),
		.out_data_ready(data_ready_3),

		.in_token(token_1),
		.in_token_valid(token_valid_1),

		.out_token(token_2),
		.out_token_valid(token_valid_2),

		.dbg_read(dbg_2_read),
		.dbg_write(dbg_2_write),
		.dbg_address(dbg_2_address[2:0]),
		.dbg_readdata(dbg_2_readdata),
		.dbg_writedata(dbg_2_writedata),
		.dbg_waitrequest(dbg_2_waitrequest),

		.*
	);

	sim_slave smp_dbg_2
	(
		.read(dbg_2_read),
		.write(dbg_2_write),
		.address(dbg_2_address),
		.readdata(dbg_2_readdata),
		.writedata(dbg_2_writedata),
		.waitrequest(dbg_2_waitrequest),

		.*
	);

	cache #(.TOKEN_AT_RESET(1)) cache_3
	(
		.core_address(cpu_3_address[31:2]),
		.core_read(cpu_3_read),
		.core_write(cpu_3_write),
		.core_lock(cpu_3_lock),
		.core_writedata(cpu_3_writedata),
		.core_byteenable(cpu_3_byteenable),
		.core_waitrequest(cpu_3_waitrequest),
		.core_response(cpu_3_response),
		.core_readdata(cpu_3_readdata),

		.mem_waitrequest(mem_3_waitrequest),
		.mem_readdata(mem_3_readdata),
		.mem_address(mem_3_address),
		.mem_read(mem_3_read),
		.mem_write(mem_3_write),
		.mem_writedata(mem_3_writedata),
		.mem_byteenable(mem_3_byteenable),

		.in_data_valid(data_valid_2),
		.in_data(data_2),
		.in_data_ready(data_ready_3),

		.out_data_valid(data_valid_3),
		.out_data(data_3),
		.out_data_ready(data_ready_0),

		.in_token(token_2),
		.in_token_valid(token_valid_2),

		.out_token(token_3),
		.out_token_valid(token_valid_3),

		.dbg_read(dbg_3_read),
		.dbg_write(dbg_3_write),
		.dbg_address(dbg_3_address[2:0]),
		.dbg_readdata(dbg_3_readdata),
		.dbg_writedata(dbg_3_writedata),
		.dbg_waitrequest(dbg_3_waitrequest),

		.*
	);

	sim_slave smp_dbg_3
	(
		.read(dbg_3_read),
		.write(dbg_3_write),
		.address(dbg_3_address),
		.readdata(dbg_3_readdata),
		.writedata(dbg_3_writedata),
		.waitrequest(dbg_3_waitrequest),

		.*
	);

	word smp_readdata, smp_writedata;
	logic smp_read, smp_write;

	sim_slave smp_sim
	(
		.read(smp_read),
		.write(smp_write),
		.address(),
		.readdata(smp_readdata),
		.writedata(smp_writedata),
		.waitrequest(0),

		.*
	);

	logic step_0, step_1, step_2, step_3,
	      halt_0, halt_1, halt_2, halt_3,
	      breakpoint_0, breakpoint_1, breakpoint_2, breakpoint_3,
	      cpu_halted_0, cpu_halted_1, cpu_halted_2, cpu_halted_3;

	smp_ctrl smp
	(
		.avl_read(smp_read),
		.avl_write(smp_write),
		.avl_writedata(smp_writedata),
		.avl_readdata(smp_readdata),

		.*
	);

	mem_interconnect mem
	(
		.*
	);

endmodule
