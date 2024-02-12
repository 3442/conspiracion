module vga_domain
(
	input logic clk_clk,
	            reset_reset_n /*verilator public*/
);

	logic[25:0] avl_address /*verilator public*/;
	logic       avl_read /*verilator public*/;
	logic       avl_write /*verilator public*/;
	logic       avl_irq /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[15:0] avl_readdata /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic[31:0] avl_writedata /*verilator public*/;
	logic       avl_waitrequest /*verilator public_flat_rw @(negedge clk_clk)*/;
	logic       avl_readdatavalid;
	logic[3:0]  avl_byteenable /*verilator public*/;

	assign avl_write = 0;
	assign avl_readdatavalid = avl_read && !avl_waitrequest;

	logic       vga_clk /*verilator public*/;
	logic       vga_hsync /*verilator public*/;
	logic       vga_vsync /*verilator public*/;
	logic       vga_blank_n /*verilator public*/;
	logic       vga_sync_n /*verilator public*/;
	logic[7:0]  vga_r /*verilator public*/;
	logic[7:0]  vga_g /*verilator public*/;
	logic[7:0]  vga_b  /*verilator public*/;

	/*vga crtc
	(
		.clk(clk_clk),
		.rst_n(reset_reset_n),
		.*
	);*/

endmodule
