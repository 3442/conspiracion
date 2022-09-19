module platform (
		input  wire        clk_clk,               //           clk.clk
		input  wire [29:0] master_0_core_addr    /*verilator public*/,// master_0_core.addr
		output wire [31:0] master_0_core_data_rd /*verilator public*/,//              .data_rd
		input  wire [31:0] master_0_core_data_wr /*verilator public*/,//              .data_wr
		output wire        master_0_core_ready   /*verilator public*/,//              .ready
		input  wire        master_0_core_write   /*verilator public*/,//              .write
		input  wire        master_0_core_start   /*verilator public*/,//              .start
		output wire [12:0] memory_mem_a,          //        memory.mem_a
		output wire [2:0]  memory_mem_ba,         //              .mem_ba
		output wire        memory_mem_ck,         //              .mem_ck
		output wire        memory_mem_ck_n,       //              .mem_ck_n
		output wire        memory_mem_cke,        //              .mem_cke
		output wire        memory_mem_cs_n,       //              .mem_cs_n
		output wire        memory_mem_ras_n,      //              .mem_ras_n
		output wire        memory_mem_cas_n,      //              .mem_cas_n
		output wire        memory_mem_we_n,       //              .mem_we_n
		output wire        memory_mem_reset_n,    //              .mem_reset_n
		inout  wire [7:0]  memory_mem_dq,         //              .mem_dq
		inout  wire        memory_mem_dqs,        //              .mem_dqs
		inout  wire        memory_mem_dqs_n,      //              .mem_dqs_n
		output wire        memory_mem_odt,        //              .mem_odt
		output wire        memory_mem_dm,         //              .mem_dm
		input  wire        memory_oct_rzqin,      //              .oct_rzqin
		input  wire        reset_reset_n          //         reset.reset_n
	);

	logic[31:0] avl_address /*verilator public*/;
	logic       avl_read /*verilator public*/;
	logic       avl_write /*verilator public*/;
	logic[31:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_writedata /*verilator public*/;
	logic       avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[3:0]  avl_byteenable /*verilator public*/;

	bus_master master_0
	(
		.clk(clk_clk),
		.rst(!reset_reset_n),
		.addr(master_0_core_addr),
		.start(master_0_core_start),
		.write(master_0_core_write),
		.ready(master_0_core_ready),
		.data_rd(master_0_core_data_rd),
		.data_wr(master_0_core_data_wr),
		.*
	);

endmodule
