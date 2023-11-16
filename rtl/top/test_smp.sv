module test_smp
(
	input  logic	   clk,
	                   rst_n,

	input  logic       avl_address, // No se usa, pero cocotb_bus lo requiere
	                   avl_read,
	                   avl_write,
	input  logic[31:0] avl_writedata,
	output logic[31:0] avl_readdata,

	input logic        cpu_alive_0,
	                   cpu_alive_1,
	                   cpu_alive_2,
	                   cpu_alive_3,
	                   cpu_halted_0,
	                   cpu_halted_1,
	                   cpu_halted_2,
	                   cpu_halted_3,
	                   breakpoint_0,
	                   breakpoint_1,
	                   breakpoint_2,
	                   breakpoint_3,	

	output logic       halt_0,
	                   halt_1,
	                   halt_2,
	                   halt_3,
	                   step_0,
	                   step_1,
	                   step_2,
	                   step_3
);

	smp_ctrl dut
	(
		.*
	);

endmodule
