`include "gfx/gfx_defs.sv"

module gfx_sp_widener
#(parameter WIDTH=0) // Quartus no soporta 'parameter type'
(
	input  logic                   clk,
	                               rst_n,

	input  logic                   word_waitrequest,
	                               word_readdatavalid,
	input  vram_word               word_readdata,
	output vram_addr               word_address,
	output logic                   word_read,

	input  logic                   wide_read,
	input  logic[WIDTH - 1:0]      wide_address,
	output logic                   wide_waitrequest,
	                               wide_readdatavalid,

	output logic[DATA_WIDTH - 1:0] wide_readdata
);

	// Este módulo existe para fingir que la DE1-SoC tiene un bus de SDRAM más ancho

	localparam WIDE_BITS = $bits(vram_addr) - WIDTH,
	           WIDE_SIZE = 1 << WIDE_BITS,
	           DATA_WIDTH = $bits(vram_word) << WIDE_BITS;

	vram_word shift_in[WIDE_SIZE];
	logic[WIDE_BITS - 1:0] address_count, read_count;

	assign word_read = wide_read;
	assign word_address = {wide_address, address_count};
	assign wide_waitrequest = word_waitrequest || !(&address_count);

	always_comb
		for (integer i = 0; i < WIDE_SIZE; ++i)
			wide_readdata[$bits(vram_word) * i +: $bits(vram_word)] = shift_in[i];

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			read_count <= 0;
			address_count <= 0;
			wide_readdatavalid <= 0;
		end else begin
			if (word_read && !word_waitrequest)
				address_count <= address_count + 1;

			if (word_readdatavalid)
				read_count <= read_count + 1;

			wide_readdatavalid <= word_readdatavalid && &read_count;
		end

	always_ff @(posedge clk)
		if (word_readdatavalid) begin
			for (integer i = 0; i < WIDE_SIZE - 1; ++i)
				shift_in[i] <= shift_in[i + 1];

			shift_in[WIDE_SIZE - 1] <= word_readdata;
		end

endmodule
