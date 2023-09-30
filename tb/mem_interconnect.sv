module mem_interconnect
(
	input  logic        clk,
	                    rst_n,

	input  logic        avl_waitrequest,
	input  logic[127:0] avl_readdata,
	output logic[31:0]  avl_address,
	output logic        avl_read,
	                    avl_write,
	output logic[127:0] avl_writedata,
	output logic[15:0]  avl_byteenable,

	input  logic[31:0]  mem_0_address,
	                    mem_1_address,
	                    mem_2_address,
	                    mem_3_address,
	input  logic        mem_0_read,
	                    mem_1_read,
	                    mem_2_read,
	                    mem_3_read,
	                    mem_0_write,
	                    mem_1_write,
	                    mem_2_write,
	                    mem_3_write,
	input  logic[127:0] mem_0_writedata,
	                    mem_1_writedata,
	                    mem_2_writedata,
	                    mem_3_writedata,
	input  logic[15:0]  mem_0_byteenable,
	                    mem_1_byteenable,
	                    mem_2_byteenable,
	                    mem_3_byteenable,
	output logic        mem_0_waitrequest,
	                    mem_1_waitrequest,
	                    mem_2_waitrequest,
	                    mem_3_waitrequest,
	output logic[127:0] mem_0_readdata,
	                    mem_1_readdata,
	                    mem_2_readdata,
	                    mem_3_readdata
);

	logic last_hold;
	logic[1:0] last_select, select;

	assign mem_0_readdata = avl_readdata;
	assign mem_1_readdata = avl_readdata;
	assign mem_2_readdata = avl_readdata;
	assign mem_3_readdata = avl_readdata;

	always_comb begin
		// Arbitraje round-robin
		unique case (last_select)
			2'd0:
				if (mem_1_read || mem_1_write)
					select = 2'd1;
				else if (mem_2_read || mem_2_write)
					select = 2'd2;
				else if (mem_3_read || mem_3_write)
					select = 2'd3;
				else
					select = 2'd0;

			2'd1:
				if (mem_2_read || mem_2_write)
					select = 2'd2;
				else if (mem_3_read || mem_3_write)
					select = 2'd3;
				else if (mem_0_read || mem_0_write)
					select = 2'd0;
				else
					select = 2'd1;

			2'd2:
				if (mem_3_read || mem_3_write)
					select = 2'd3;
				else if (mem_0_read || mem_0_write)
					select = 2'd0;
				else if (mem_1_read || mem_1_write)
					select = 2'd1;
				else
					select = 2'd2;

			2'd3:
				if (mem_0_read || mem_0_write)
					select = 2'd0;
				else if (mem_1_read || mem_1_write)
					select = 2'd1;
				else if (mem_2_read || mem_2_write)
					select = 2'd2;
				else
					select = 2'd3;
		endcase

		if (last_hold)
			select = last_select;

		mem_0_waitrequest = 1;
		mem_1_waitrequest = 1;
		mem_2_waitrequest = 1;
		mem_3_waitrequest = 1;

		unique case (select)
			2'd0: begin
				avl_read = mem_0_read;
				avl_write = mem_0_write;
				avl_address = mem_0_address;
				avl_writedata = mem_0_writedata;
				avl_byteenable = mem_0_byteenable;
				mem_0_waitrequest = avl_waitrequest;
			end

			2'd1: begin
				avl_read = mem_1_read;
				avl_write = mem_1_write;
				avl_address = mem_1_address;
				avl_writedata = mem_1_writedata;
				avl_byteenable = mem_1_byteenable;
				mem_1_waitrequest = avl_waitrequest;
			end

			2'd2: begin
				avl_read = mem_2_read;
				avl_write = mem_2_write;
				avl_address = mem_2_address;
				avl_writedata = mem_2_writedata;
				avl_byteenable = mem_2_byteenable;
				mem_2_waitrequest = avl_waitrequest;
			end

			2'd3: begin
				avl_read = mem_3_read;
				avl_write = mem_3_write;
				avl_address = mem_3_address;
				avl_writedata = mem_3_writedata;
				avl_byteenable = mem_3_byteenable;
				mem_3_waitrequest = avl_waitrequest;
			end
		endcase
	end

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			last_hold <= 1;
			last_select <= 2'd0;
		end else begin
			last_hold <= (avl_read || avl_write) && avl_waitrequest;
			last_select <= select;
		end

endmodule
