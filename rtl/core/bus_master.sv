`include "core/uarch.sv"

module bus_master
(
	input  logic      clk,
	                  rst_n,

	output word       avl_address,
	output logic      avl_read,
	                  avl_write,
	                  avl_lock,
	input  word       avl_readdata,
	output word       avl_writedata,
	input  logic      avl_waitrequest,
	input  logic[1:0] avl_response,
	output logic[3:0] avl_byteenable,

	input  logic      start,
	                  write,
	                  ex_lock,
	input  ptr        addr,
	input  logic[3:0] data_be,
	input  word       data_wr,
	output logic      ready,
	                  ex_fail,
	output word       data_rd
);

	enum int unsigned
	{
		IDLE,
		WAIT
	} state;

	assign data_rd = avl_readdata;
	assign ex_fail = |avl_response;

	always_comb
		unique case (state)
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
		end else if ((state == IDLE || !avl_waitrequest) && start) begin
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
