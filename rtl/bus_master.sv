module bus_master
(
	input  logic       clk,
	                   rst,

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

	always_ff @(posedge clk) begin
		unique case(state)
			IDLE: begin
				avl_read <= 0;
				avl_write <= 0;
			end

			WAIT:
				if(!start)
					state <= IDLE;
		endcase

		if(!avl_waitrequest && start) begin
			avl_address <= {addr, 2'b00};
			avl_read <= ~write;
			avl_write <= write;
			avl_writedata <= data_wr;
			state <= WAIT;
		end
	end

	initial begin
		state = IDLE;
		avl_read = 0;
		avl_write = 0;
	end

endmodule
