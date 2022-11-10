module bus_master
(
	input  logic       clk,
	                   rst_n,

	input  logic[29:0] addr,
	input  logic       start,
	                   write,
	output logic       ready,
	output logic[31:0] data_rd,
	input  logic[31:0] data_wr,
	output logic       cpu_clk,
	                   irq,

	output logic[31:0] avl_address,
	output logic       avl_read,
	                   avl_write,
	input  logic[31:0] avl_readdata,
	output logic[31:0] avl_writedata,
	input  logic       avl_waitrequest,
	output logic[3:0]  avl_byteenable,
	input  logic       avl_irq
);

	enum {
		IDLE,
		WAIT
	} state;

	assign irq = avl_irq;
	assign cpu_clk = clk;

	assign data_rd = avl_readdata;
	assign avl_byteenable = 4'b1111; //TODO

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
			avl_read <= 0;
			avl_write <= 0;
			avl_address <= 0;
			avl_writedata <= 0;
		end else if((state == IDLE || !avl_waitrequest) && start) begin
			state <= WAIT;
			avl_read <= ~write;
			avl_write <= write;
			avl_address <= {addr, 2'b00};
			avl_writedata <= data_wr;
		end else if(state == WAIT && !avl_waitrequest) begin
			state <= IDLE;
			avl_read <= 0;
			avl_write <= 0;
		end

endmodule
