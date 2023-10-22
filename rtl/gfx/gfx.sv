`include "gfx/gfx_defs.sv"

module gfx
(
	input  logic       clk,
	                   rst_n,

	input  logic[4:0]  cmd_address,
	input  logic       cmd_read,
	                   cmd_write,
	input  logic[31:0] cmd_writedata,
	output logic[31:0] cmd_readdata
);

	fp readdata, writedata;
	mat4 a, b, q, hold_q;
	logic start, done;

	assign readdata = hold_q[cmd_address[3:2]][cmd_address[1:0]];
	assign writedata = cmd_writedata[`FLOAT_BITS - 1:0];
	assign cmd_readdata = {{($bits(cmd_readdata) - `FLOAT_BITS){1'b0}}, readdata};

	mat_mat_mul mul
	(
		.in_ready(),
		.in_valid(start),
		.out_ready(1),
		.out_valid(done),
		.*
	);

	always_ff @(posedge clk) begin
		if (cmd_write) begin
			if (cmd_address[4])
				a[cmd_address[3:2]][cmd_address[1:0]] <= writedata;
			else
				b[cmd_address[3:2]][cmd_address[1:0]] <= writedata;
		end

		if (done)
			hold_q <= q;
	end

	always_ff @(posedge clk or negedge rst_n)
		start <= !rst_n ? 0 : (cmd_write && cmd_address == 5'b11111);

endmodule
