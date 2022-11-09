module conspiracion
(
	input  wire        clk_clk,
	input  wire        debug,
	output wire [12:0] memory_mem_a,
	output wire [2:0]  memory_mem_ba,
	output wire        memory_mem_ck,
	output wire        memory_mem_ck_n,
	output wire        memory_mem_cke,
	output wire        memory_mem_cs_n,
	output wire        memory_mem_ras_n,
	output wire        memory_mem_cas_n,
	output wire        memory_mem_we_n,
	output wire        memory_mem_reset_n,
	inout  wire [7:0]  memory_mem_dq,
	inout  wire        memory_mem_dqs,
	inout  wire        memory_mem_dqs_n,
	output wire        memory_mem_odt,
	output wire        memory_mem_dm,
	input  wire        memory_oct_rzqin,
	output wire        vram_wire_clk,
	output wire [12:0] vram_wire_addr,
	output wire [1:0]  vram_wire_ba,
	output wire        vram_wire_cas_n,
	output wire        vram_wire_cke,
	output wire        vram_wire_cs_n,
	inout  wire [15:0] vram_wire_dq,
	output wire [1:0]  vram_wire_dqm,
	output wire        vram_wire_ras_n,
	output wire        vram_wire_we_n,
	output wire [7:0]  pio_leds,
	output wire        vga_controller_0_dac_clk,
	output wire        vga_controller_0_dac_hsync,
	output wire        vga_controller_0_dac_vsync,
	output wire        vga_controller_0_dac_blank_n,
	output wire        vga_controller_0_dac_sync_n,
	output wire [7:0]  vga_controller_0_dac_r,
	output wire [7:0]  vga_controller_0_dac_g,
	output wire [7:0]  vga_controller_0_dac_b
);

	//TODO
	wire reset_reset_n;
	assign reset_reset_n = 1'b1;

	logic[29:0] addr;
	logic[31:0] data_rd, data_wr;
	logic cpu_clk, ready, write, start, irq;

	arm810 core
	(
		.clk(cpu_clk),
		.bus_addr(addr),
		.bus_data_rd(data_rd),
		.bus_data_wr(data_wr),
		.bus_ready(ready),
		.bus_write(write),
		.bus_start(start),
		.*
	);

	platform plat
	(
		.master_0_core_cpu_clk(cpu_clk),
		.master_0_core_addr(addr),
		.master_0_core_data_rd(data_rd),
		.master_0_core_data_wr(data_wr),
		.master_0_core_ready(ready),
		.master_0_core_write(write),
		.master_0_core_start(start),
		.master_0_core_irq(irq),
		.pll_0_outclk3_clk(vram_wire_clk),
		.pio_0_external_connection_export(pio_leds),
		.*
	);

endmodule
