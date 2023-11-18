module test_fifo
(
	input  logic      clk,
	                  rst_n,

	input  logic[7:0] in,
	input  logic      in_valid,
	output logic      in_ready,

	input  logic      out_ready,
	output logic      out_valid,
	output logic[7:0] out
);

	gfx_fifo #(.WIDTH($bits(in)), .DEPTH(8)) dut
	(
		.*
	);

endmodule
