`include "core/uarch.sv"
`include "config.sv"

module core
#(parameter ID=0)
(
	input  logic      clk,
	                  rst_n,

	input  wire       step,
	input  wire       cpu_halt,
	output wire       cpu_alive,
	output wire       cpu_halted,
	output wire       breakpoint,

	output word       avl_address,
	output logic      avl_read,
	                  avl_write,
	                  avl_lock,
	input  word       avl_readdata,
	output word       avl_writedata,
	input  logic      avl_waitrequest,
	input  logic[1:0] avl_response,
	output logic[3:0] avl_byteenable,

	input  logic      avl_irq
);

	generate
		if (ID < `CONFIG_CPUS) begin: enable
			assign cpu_alive = 1;

			ptr addr;
			word data_wr;
			logic start, write;
			logic[3:0] data_be;

			arm810 cpu
			(
				.irq(avl_irq),
				.halt(cpu_halt),
				.halted(cpu_halted),
				.bus_addr(addr),
				.bus_data_rd(data_rd),
				.bus_data_wr(data_wr),
				.bus_data_be(data_be),
				.bus_ready(ready),
				.bus_write(write),
				.bus_start(start),
				.bus_ex_fail(ex_fail),
				.bus_ex_lock(ex_lock),
				.*
			);

			word data_rd;
			logic ex_fail, ex_lock, ready;

			bus_master master
			(
				.*
			);
		end else begin
			assign cpu_alive = 0;
			assign cpu_halted = 1;
			assign breakpoint = 0;

			assign avl_lock = 0;
			assign avl_read = 0;
			assign avl_write = 0;
		end
	endgenerate

endmodule
