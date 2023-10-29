module test_fb
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
	output logic[15:0] mem_writedata,

	input  logic       scan_ready,
	output logic       scan_valid,
	                   scan_endofpacket,
	                   scan_startofpacket,
	output logic[29:0] scan_data
);

	gfx dut
	(
		.*
	);

endmodule
