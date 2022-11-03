`define COORD_BITS 10

`define VGA_PIXCLK_HZ 25_175_000

module vga
(
	input  logic       clk,
	input  logic       rst_n,

	output logic[25:0] avl_address,
	output logic       avl_read,
	input  logic[31:0] avl_readdata,
	input  logic       avl_waitrequest,

	output logic       vga_clk,
	                   vga_hsync,
	                   vga_vsync,
	                   vga_blank_n,
	                   vga_sync_n,
	output logic[7:0]  vga_r,
	                   vga_g,
	                   vga_b
);

	localparam H_ACTIVE = `COORD_BITS'd640;
	localparam H_FPORCH = `COORD_BITS'd16;
	localparam H_SYNC   = `COORD_BITS'd96;
	localparam H_BPORCH = `COORD_BITS'd48;
	localparam V_ACTIVE = `COORD_BITS'd480;
	localparam V_FPORCH = `COORD_BITS'd11;
	localparam V_SYNC   = `COORD_BITS'd2;
	localparam V_BPORCH = `COORD_BITS'd31;

	localparam H_SYNC_AT = H_BPORCH + H_ACTIVE + H_FPORCH;
	localparam H_TOTAL   = H_SYNC_AT + H_SYNC;
	localparam V_SYNC_AT = V_BPORCH + V_ACTIVE + V_FPORCH;
	localparam V_TOTAL   = V_SYNC_AT + V_SYNC;

	logic[7:0] r, g, b;

	assign vga_clk = clk;
	assign vga_blank_n = 1;
	assign vga_sync_n = 0;

endmodule
