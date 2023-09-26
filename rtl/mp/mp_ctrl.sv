module mp_ctrl
(
	input  logic	   clk,
	                   rst_n,
	
	input  logic       avl_read,
	                   avl_write,
	input  logic[31:0] avl_writedata,
	output logic[31:0] avl_readdata,

	input logic        cpu_halted_0,
	                   cpu_halted_1,
	                   cpu_halted_2,
	                   cpu_halted_3,
	input logic        breakpoint_0,
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

	logic write;
	logic[7:0] readdata_3, readdata_2, readdata_1, readdata_0,
	           writedata_3, writedata_2, writedata_1, writedata_0;

	assign avl_readdata = {readdata_3, readdata_2, readdata_1, readdata_0};
	assign {writedata_3, writedata_2, writedata_1, writedata_0} = avl_writedata;

	// No hay addresses
	assign write = avl_write;

	mp_pe pe_1
	(
		.step(step_1),
		.halt(halt_1),
		.cpu_halted(cpu_halted_1),
		.breakpoint(breakpoint_1),
		.readdata(readdata_1),
		.writedata(writedata_1),
		.*
	);

	mp_pe pe_2
	(
		.step(step_2),
		.halt(halt_2),
		.cpu_halted(cpu_halted_2),
		.breakpoint(breakpoint_2),
		.readdata(readdata_2),
		.writedata(writedata_2),
		.*
	);

	mp_pe pe_3
	(
		.step(step_3),
		.halt(halt_3),
		.cpu_halted(cpu_halted_3),
		.breakpoint(breakpoint_3),
		.readdata(readdata_3),
		.writedata(writedata_3),
		.*
	);

endmodule
