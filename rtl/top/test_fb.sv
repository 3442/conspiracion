`include "gfx/gfx_defs.sv"

module test_fb
(
	input  logic          clk,
	                      rst_n,

	input  cmd_addr       cmd_address,
	input  logic          cmd_read,
	                      cmd_write,
	input  cmd_word       cmd_writedata,
	output cmd_word       cmd_readdata,

	input  logic          mem_waitrequest,
	                      mem_readdatavalid,
	input  vram_word      mem_readdata,
	output vram_byte_addr mem_address,
	output logic          mem_read,
	                      mem_write,
	output vram_word      mem_writedata,

	input  vram_addr      host_address,
	input  logic          host_read,
	                      host_write,
	input  vram_word      host_writedata,
	output logic          host_waitrequest,
	                      host_readdatavalid,
	output vram_word      host_readdata,

	input  logic          scan_ready,
	output logic          scan_valid,
	                      scan_endofpacket,
	                      scan_startofpacket,
	output rgb30          scan_data
);

	gfx dut
	(
		.*
	);

endmodule
