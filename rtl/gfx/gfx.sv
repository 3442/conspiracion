`include "gfx/gfx_defs.sv"

module gfx
(
	input  logic       clk,
	                   rst_n,

	input  logic[5:0]  cmd_address,
	input  logic       cmd_read,
	                   cmd_write,
	input  logic[31:0] cmd_writedata,
	output logic[31:0] cmd_readdata,

	input  logic       mem_waitrequest,
	                   mem_readdatavalid,
	input  logic[15:0] mem_readdata,
	output logic[25:0] mem_address,
	output logic       mem_read,
	                   mem_write,
	output logic[15:0] mem_writedata
);

	fp readdata, writedata;
	mat4 a, b, q, hold_q;
	logic start, done;

	assign mem_read = 1;
	assign mem_write = 0;

	assign readdata = hold_q[cmd_address[3:2]][cmd_address[1:0]];
	assign writedata = cmd_writedata[`FLOAT_BITS - 1:0];

	always_comb begin
		if (!cmd_address[5])
			cmd_readdata = {{($bits(cmd_readdata) - `FLOAT_BITS){1'b0}}, readdata};
		else if (cmd_address[4])
			cmd_readdata = cmd_address[0] ? cnt_done : cnt_start;
		else
			unique case (cmd_address[1:0])
				2'b00:
					cmd_readdata = snp_trans[31:0];

				2'b01:
					cmd_readdata = snp_trans[63:32];

				2'b10:
					cmd_readdata = snp_cycles[31:0];

				2'b11:
					cmd_readdata = snp_cycles[63:32];
			endcase
	end

	mat_mat_mul mul
	(
		.in_ready(),
		.in_valid(start),
		.out_ready(1),
		.out_valid(done),
		.*
	);

	logic[63:0] cnt_cycles, cnt_trans, snp_cycles, snp_trans;
	logic[24:0] cnt_addr;
	logic[31:0] cnt_done, cnt_start;
	assign mem_address = {cnt_addr, 1'b0};

	always_ff @(posedge clk) begin
		if (cmd_write) begin
			if (cmd_address[4])
				b[cmd_address[3:2]][cmd_address[1:0]] <= writedata;
			else
				a[cmd_address[3:2]][cmd_address[1:0]] <= writedata;

			snp_trans <= cnt_trans;
			snp_cycles <= cnt_cycles;
		end

		if (done)
			hold_q <= q;
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			start <= 0;
			cnt_addr <= 0;
			cnt_trans <= 0;
			cnt_cycles <= 0;
			cnt_done <= 0;
			cnt_start <= 0;
		end else begin
			start <= cmd_write;
			cnt_cycles <= cnt_cycles + 1;

			if (start)
				cnt_start <= cnt_start + 1;

			if (done)
				cnt_done <= cnt_done + 1;

			if (!mem_waitrequest)
				cnt_addr <= cnt_addr + 1;

			if (mem_readdatavalid)
				cnt_trans <= cnt_trans + 1;
		end

endmodule
