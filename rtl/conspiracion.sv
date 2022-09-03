module conspiracion
(
	input  wire        clk_clk,            //    clk.clk
	output wire [12:0] memory_mem_a,       // memory.mem_a
	output wire [2:0]  memory_mem_ba,      //       .mem_ba
	output wire        memory_mem_ck,      //       .mem_ck
	output wire        memory_mem_ck_n,    //       .mem_ck_n
	output wire        memory_mem_cke,     //       .mem_cke
	output wire        memory_mem_cs_n,    //       .mem_cs_n
	output wire        memory_mem_ras_n,   //       .mem_ras_n
	output wire        memory_mem_cas_n,   //       .mem_cas_n
	output wire        memory_mem_we_n,    //       .mem_we_n
	output wire        memory_mem_reset_n, //       .mem_reset_n
	inout  wire [7:0]  memory_mem_dq,      //       .mem_dq
	inout  wire        memory_mem_dqs,     //       .mem_dqs
	inout  wire        memory_mem_dqs_n,   //       .mem_dqs_n
	output wire        memory_mem_odt,     //       .mem_odt
	output wire        memory_mem_dm,      //       .mem_dm
	input  wire        memory_oct_rzqin,   //       .oct_rzqin
	input  wire        reset_reset_n       //  reset.reset_n
);

	platform plat(.*);

endmodule
