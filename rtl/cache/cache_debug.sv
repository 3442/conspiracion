`include "cache/defs.sv"

module cache_debug
(
	input  logic      clk,
	                  rst_n,

	input  logic[2:0] dbg_address,		// Dirección del slave
	input  logic      dbg_read,
	input  word       dbg_writedata,	// Dirección que se quiere leer
	output logic      dbg_waitrequest,
	output word       dbg_readdata,		// Es cada word de la salida de la 
										// lectura de la line
	input  logic      debug_ready,
	input  addr_tag   tag_rd,
	input  line       data_rd,
	input  line_state state_rd,
	output addr_index debug_index
);

	// Módulo que a partir de un address de cache, "retorna" los datos (cada 
	// una de las words) de la línea consultad, así como metadata de la línea
	// (estado, si es cached, index, tad, etc)

	// Este struct es lo que lee cache.c a través de las direcciones de memoria 
	// para desplegarlo en la CLI
	struct packed
	{
		logic[2:0] mbz_0;
		addr_tag   tag;
		addr_index index;
		line_state state;
		logic      cached,
		           mbz_1;
	} status;	// Esto representa una línea de cache

	line line_dump;
	word word_dump, word_3, word_2, word_1, word_0;
	addr_bits debug_addr_bits;

	logic cached;
	addr_tag tag;
	addr_index index;
	line_state state;

	assign debug_index = debug_addr_bits.index;
	assign dbg_readdata = dbg_address[2] ? word_dump : status;
	assign dbg_waitrequest = !debug_ready && !dbg_read;

	assign status.tag = tag;
	assign status.index = index;
	assign status.state = state;
	assign status.mbz_0 = 3'b000;
	assign status.mbz_1 = 0;
	assign status.cached = cached;
	assign debug_addr_bits = dbg_writedata;

	assign {word_3, word_2, word_1, word_0} = line_dump;

	// Acá se define cuál es la word actual de la línea que se va a leer
	always_comb
		unique case (dbg_address[1:0])
			2'b00: word_dump = word_0;
			2'b01: word_dump = word_1;
			2'b10: word_dump = word_2;
			2'b11: word_dump = word_3;
		endcase

	always @(posedge clk)
		if (debug_ready) begin
			tag <= tag_rd;
			index <= debug_addr_bits.index;
			state <= state_rd;
			cached <= !(|debug_addr_bits.io);
			line_dump <= data_rd;
		end

endmodule
