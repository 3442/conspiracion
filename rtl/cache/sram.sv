`include "cache/defs.sv"

module cache_sram
(
	input  logic      clk,
	                  rst_n,

	input  addr_index index_rd,
	                  index_wr,
	input  logic      write_data,
	                  write_state,
	input  addr_tag   tag_wr,
	input  line       data_wr,
	input  line_state state_wr,

	output addr_tag   tag_rd,
	output line       data_rd,
	output line_state state_rd
);

	// Existe un mito que habla de true dual-ports con byte-enables, dudo mucho que sea real:
	// https://www.intel.com/content/www/us/en/docs/programmable/683082/21-3/ram-with-byte-enable-signals.html

	// Define la cantidad de líneas de cache
	// $bits(addr_index) = 9 --> 1 << 9 = 512
	localparam DEPTH = 1 << $bits(addr_index);

	line data_file[DEPTH] /*verilator public*/;
	addr_tag tag_file[DEPTH] /*verilator public*/;
	line_state state_file[DEPTH] /*verilator public*/;
	
	/* 3 funciones principales:
	 * 	1. Si se necesita escribir un dato: escribe en los tag y data files en la posición del index de escritura
	 *	2. Si se necesita escribir un estado: escribe en el state file en la posición del index de escritura
	 *	3. Cada ciclo retorna siempre lo que esté en todos los files en la posición de index de lectura
	 */
	always_ff @(posedge clk) begin
		if (write_data) begin
			tag_file[index_wr] <= tag_wr;
			data_file[index_wr] <= data_wr;
		end

		if (write_state)
			state_file[index_wr] <= state_wr;

		tag_rd <= tag_file[index_rd];
		data_rd <= data_file[index_rd];
		state_rd <= state_file[index_rd];
	end

	// Se inicializan todas las líneas del state file como INVALID
	//FIXME: rst_n para state_file?
	initial
		for (int i = 0; i < DEPTH; ++i)
			state_file[i] = INVALID;

endmodule
