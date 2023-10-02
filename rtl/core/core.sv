`include "core/uarch.sv"

module core
(
	input  logic      clk,
	                  rst_n,

	input  wire       step,
	input  wire       cpu_halt,
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

	logic ex_fail, ex_lock, start, ready, write;

	logic[3:0] data_be;
	logic[29:0] addr;
	logic[31:0] data_rd, data_wr;

	enum int unsigned
	{
		IDLE,
		WAIT
	} state;

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

	assign data_rd = avl_readdata;
	assign ex_fail = |avl_response;

	always_comb
		unique case(state)
			IDLE: ready = 0;
			WAIT: ready = !avl_waitrequest;
		endcase

	always_ff @(posedge clk or negedge rst_n)
		/* P. 16:
		 * A host must make no assumption about the assertion state of
		 * waitrequest when the host is idle: waitrequest may be high or
		 * low, depending on system properties. When waitrequest is asserted,
		 * host control signals to the agent must remain constant except for
		 * beginbursttransfer.
		 */
		if(!rst_n) begin
			state <= IDLE;
			avl_lock <= 0;
			avl_read <= 0;
			avl_write <= 0;
			avl_address <= 0;
			avl_writedata <= 0;
			avl_byteenable <= 0;
		end else if((state == IDLE || !avl_waitrequest) && start) begin
			state <= WAIT;
			avl_lock <= ex_lock;
			avl_read <= ~write;
			avl_write <= write;
			avl_address <= {addr, 2'b00};
			avl_writedata <= data_wr;
			avl_byteenable <= write ? data_be : 4'b1111;
		end else if(state == WAIT && !avl_waitrequest) begin
			state <= IDLE;
			avl_read <= 0;
			avl_write <= 0;
		end

endmodule
