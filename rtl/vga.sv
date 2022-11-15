`define COORD_BITS 10

`define VGA_PIXCLK_HZ 25_175_000

/* Todas las constantes mágicas están en el DE1-SoC CD-ROM bajo
 * Datasheet/SDRAM/IS42R16320D.pdf
 * 
 * Este módulo es el CRTC de VGA. Consideraciones:
 *
 * - Se necesita una resolución clásica de 640x480 @ ~60Hz.
 *
 * - La VRAM en este caso es una unidad de memoria dinámica real, externa a la
 *   fábrica de la FPGA, que tiene todas las propiedades esperables de SDRAM
 *   real, como cálculos de temporización e impedancias, latencia de más de un
 *   ciclo, strobe, etc.
 *
 * - Este módulo debe generar una señal para el DAC que no puede detenerse,
 *   sino que debe emitir exactamente un píxel por ciclo de pixclk, excepto
 *   fuera de las regiones activas horizontal y vertical.
 *
 * - La VRAM tiene 4 bancos de 10 columnas y 13 filas con celdas de 16 bits.
 *
 * - El CPU puede escribir a VRAM al mismo tiempo que el CRTC lee, ambos son
 *   maestros de un mismo esclavo.
 *
 * Por lo tanto:
 *
 * - El formato de framebuffer es row-major r5g6b5.
 *
 * - Existen dos buffers de scanline, uno para filas pares y otro para
 *   impares.
 *
 * - Mientras el CRTC muestra una scanline en pantalla, el maestro Avalon lee
 *   la siguiente de VRAM usando pipelining para lograr esto último lo más
 *   rápido que la VRAM sea capaz. Según el *_hw.tcl del IP para VRAM, este
 *   soporta hasta siete transacciones en pipeline. Ocurrirán glitches si VRAM
 *   no es capaz de producir una scanline antes de que el CRTC la necesite.
 */

module vga
(
	input  logic       clk,
	                   rst_n,

	// 26 bits direccionan 64MiB
	output logic[25:0] avl_address,
	output logic       avl_read,
	input  logic[15:0] avl_readdata,
	input  logic       avl_waitrequest,
	                   avl_readdatavalid,

	output logic       vga_clk,
	                   vga_hsync,
	                   vga_vsync,
	                   vga_blank_n,
	                   vga_sync_n,
	output logic[7:0]  vga_r,
	                   vga_g,
	                   vga_b
);

	localparam H_ACTIVE_NO = 640;
	localparam H_ACTIVE    = `COORD_BITS'd640;
	localparam H_FPORCH    = `COORD_BITS'd16;
	localparam H_SYNC      = `COORD_BITS'd96;
	localparam H_BPORCH    = `COORD_BITS'd48;
	localparam V_ACTIVE    = `COORD_BITS'd480;
	localparam V_FPORCH    = `COORD_BITS'd11;
	localparam V_SYNC      = `COORD_BITS'd2;
	localparam V_BPORCH    = `COORD_BITS'd31;

	localparam H_FPORCH_AT = H_BPORCH + H_ACTIVE;
	localparam H_SYNC_AT   = H_FPORCH_AT + H_FPORCH;
	localparam H_TOTAL     = H_SYNC_AT + H_SYNC;
	localparam V_FPORCH_AT = V_BPORCH + V_ACTIVE;
	localparam V_SYNC_AT   = V_FPORCH_AT + V_FPORCH;
	localparam V_TOTAL     = V_SYNC_AT + V_SYNC;

	typedef struct packed
	{
		logic[4:0] r;
		logic[5:0] g;
		logic[4:0] b;
	} pix;

	enum int unsigned
	{
		A,
		B
	} reading, next_reading, fill_start_reading;

	pix current, read_a, read_b;
	pix scanline_a[H_ACTIVE_NO];
	pix scanline_b[H_ACTIVE_NO];

	logic next_active;
	logic[24:0] addr;
	logic[`COORD_BITS - 1:0] x, y, next_x, next_y, next_hsync,
	                         pending_read, pending_data, read_idx, write_idx;

	assign vga_clk = clk;
	assign vga_sync_n = 0;
	assign vga_blank_n = 1;
	assign avl_address = {addr, 1'b0};

	assign vga_r = {current.r, current.r[4], current.r[4], current.r[4]};
	assign vga_g = {current.g, current.g[5], current.g[5]};
	assign vga_b = {current.b, current.b[4], current.b[4], current.b[4]};

	assign read_idx = next_x - H_BPORCH;
	assign next_reading = next_y[0] ^ (next_x < H_FPORCH_AT) ? A : B;

	assign next_active
		=  next_x >= H_BPORCH && next_x < H_FPORCH_AT
		&& next_y >= V_BPORCH && next_y < V_FPORCH_AT;

	always_comb begin
		unique case(reading)
			A: current = read_a;
			B: current = read_b;
		endcase

		if(!next_active)
			current = {$bits(current){1'b0}};

		if(x != H_TOTAL - 1) begin
			next_x = x + 1;
			next_y = y;
		end else begin
			next_x = 0;
			next_y = y != V_TOTAL - 1 ? y + 1 : 0;
		end
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			x <= H_TOTAL - 1;
			y <= V_TOTAL - 1;
			reading <= A;
			write_idx <= 0;
			pending_read <= 0;
			pending_data <= 0;
			fill_start_reading <= A;

			read_a <= 0;
			read_b <= 0;

			addr <= 0;
			avl_read <= 0;

			vga_hsync <= 0;
			vga_vsync <= 0;
		end else begin
			if(next_active)
				unique case(next_reading)
					A: read_a <= scanline_a[read_idx];
					B: read_b <= scanline_b[read_idx];
				endcase

			if(avl_readdatavalid) begin
				unique case(fill_start_reading)
					A: scanline_b[write_idx] <= avl_readdata;
					B: scanline_a[write_idx] <= avl_readdata;
				endcase

				write_idx <= write_idx + 1;
				pending_data <= pending_data - 1;
			end

			if(!avl_read || !avl_waitrequest) begin
				avl_read <= 0;

				if(pending_read != 0) begin
					addr <= addr + 1;
					avl_read <= 1;
					pending_read <= pending_read - 1;
				end
			end

			if(pending_read == 0 && pending_data == 0 && next_reading != reading) begin
				if(y >= V_BPORCH - 2 && y < V_FPORCH_AT - 2) begin
					write_idx <= 0;
					pending_read <= H_ACTIVE;
					pending_data <= H_ACTIVE;
					fill_start_reading <= next_reading;
				end else
					addr <= {$bits(addr){1'b1}};
			end

			x <= next_x;
			y <= next_y;
			reading <= next_reading;

			vga_hsync <= next_x < H_SYNC_AT;
			vga_vsync <= next_y < V_SYNC_AT;
		end

endmodule
