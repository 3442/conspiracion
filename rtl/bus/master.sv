module bus_master
(
	input  logic       clk,
	                   rst,

	input  logic[29:0] addr,
	input  logic       start,
	                   write,
	output logic       ready,
	output logic[31:0] data_rd,
	input  logic[31:0] data_rw,

	output logic[31:0] avl_address,
	output logic       avl_read,
	                   avl_write,
	input  logic[31:0] avl_readdata,
	output logic[31:0] avl_writedata,
	input  logic       avl_waitrequest,
	output logic[3:0]  avl_byteenable
);

	enum {
		REQUEST,
		WAIT,
		RESPONSE
	} state;

	assign data_rd = avl_readdata;

	always_ff @(posedge clk) unique case(state)
		REQUEST: if(start) begin
			avl_address <= {addr, 2'b00};
			avl_read <= ~write;
			avl_write <= write;
			avl_writedata <= data_rw;
		end

		WAIT: if(~avl_waitrequest) begin
			ready <= 1;
			state <= RESPONSE;
		end

		RESPONSE: begin
			ready <= 0;
			avl_read <= 0;
			avl_write <= 0;
			state <= REQUEST;
		end
	endcase

	initial begin
		ready = 0;
		avl_read = 0;
		avl_write = 0;
		state = REQUEST;
	end

endmodule
