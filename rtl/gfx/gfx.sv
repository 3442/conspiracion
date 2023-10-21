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

	mat4 a, b, q, hold_q;
	logic start, done;

	assign cmd_readdata = hold_q[cmd_address[3:2]][cmd_address[1:0]];

	mat_mat_mul mul
	(
		.*
	);

	always_ff @(posedge clk) begin
		if (cmd_write) begin
			if (cmd_address[4])
				a[cmd_address[3:2]][cmd_address[1:0]] <= cmd_writedata;
			else
				b[cmd_address[3:2]][cmd_address[1:0]] <= cmd_writedata;
		end

		if (done)
			hold_q <= q;
	end

	always_ff @(posedge clk or negedge rst_n)
		start <= !rst_n ? 0 : (cmd_write && cmd_address == 5'b11111);

endmodule
