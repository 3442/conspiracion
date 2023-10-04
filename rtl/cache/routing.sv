`include "cache/defs.sv"

module cache_routing
(
	input  logic       clk,
	                   rst_n,

	input  ptr         core_address,
	input  logic       core_read,
	                   core_write,
	input  line        core_writedata_line,
	input  line_be     core_byteenable_line,
	output logic       core_waitrequest,
	output line        core_readdata_line,

	output addr_tag    core_tag,
	output addr_index  core_index,
	output addr_offset core_offset,

	input  line        data_rd,
	input  logic       cache_core_waitrequest,
	output logic       cache_core_read,
	                   cache_core_write,

	input  word        cache_mem_address,
	input  logic       cache_mem_read,
	                   cache_mem_write,
	input  line        cache_mem_writedata,
	output logic       cache_mem_waitrequest,

	input  logic       mem_waitrequest,
	input  line        mem_readdata,
	output word        mem_address,
	output logic       mem_read,
	                   mem_write,
	output line        mem_writedata,
	output line_be     mem_byteenable
);

	/* Módulo para enrutar las operaciones a cache o memoria 
	 * Esto porque hay escrituras que definitivamente no pueden quedar en cache
	 * como el caso de periféricos, para los cuales si se guarda "su valor" en 
	 * cache y no en memoria se harían lecturas incorrectas
	 */

	word core_address_line;
	logic cached, cache_mem, transition;
	addr_io_region io;

	enum int unsigned
	{
		IDLE,
		CACHE,
		BYPASS
	} state;

	//Arbitrar el bus del lado de la cache

	/* Se sabe si el address es cache o no evaluando los bits de IO.
	 * Esto es posible porque se cumple lo siguiente:
	 *	- La memoria tiene un tamaño que es una potencia de 2
	 *	- Sus direcciones inician en 0
	 * Entonces si los bits de IO son distintos de 0, se sabe que no es
	 * una dirección cached
	 */
	assign cached = io == 3'b000;
	// Se afirma si cache quiere hacer un read o write de memoria
	assign cache_mem = cache_mem_read || cache_mem_write;

	// Acá se divide el core_address para analizarse por separado
	assign {io, core_tag, core_index, core_offset} = core_address;
	assign core_address_line = {io, core_tag, core_index, 4'b0000};
	// Si está cached se asigna a lectura de cache, sino a lectura de memoria
	assign core_readdata_line = cached ? data_rd : mem_readdata;

	// Se afirma si el core quiere leer/escribir a cache y efectivamente es una 
	// dirección de cache
	assign cache_core_read = core_read && cached;
	assign cache_core_write = core_write && cached;

	always_comb begin
		transition = 0;
		core_waitrequest = cache_core_waitrequest;
		// Desde el punto de vista de cache, mem le hace waitreq a cache
		cache_mem_waitrequest = 1;

		unique case (state)
			IDLE:
				/* Transition se afirma si cache quiere hacer un read o write de 
				 * memoria, o si el address no es cache y el core quiere leer
				 * o escribir a cache
				 */
				transition = cache_mem || (!cached && (core_read || core_write));

			CACHE:
				// Cache le hace waitreq a memoria
				cache_mem_waitrequest = mem_waitrequest;

			BYPASS:
				// Se le hace waitreq al core si la memoria también lo hace
				core_waitrequest = mem_waitrequest;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= IDLE;
			mem_read <= 0;
			mem_write <= 0;
		end else unique case (state)
			IDLE:
				if (transition) begin
					// Si cache quiere hacer una operación con memoria, se pasa 
					// a CACHE, sino hay que hacer BYPASS 
					state <= cache_mem ? CACHE : BYPASS;
					mem_read <= cache_mem ? cache_mem_read : core_read;
					mem_write <= cache_mem ? cache_mem_write : core_write;
				end

			CACHE, BYPASS:
				if (!mem_waitrequest) begin
					state <= IDLE;
					mem_read <= 0;
					mem_write <= 0;
				end
		endcase

	always_ff @(posedge clk)
		if (transition) begin
			// Si cache no quiere hacer una operación con memoria, se asignan  
			// las señales del core
			mem_address <= cache_mem ? cache_mem_address : core_address_line;
			mem_writedata <= cache_mem ? cache_mem_writedata : core_writedata_line;
			mem_byteenable <= cache_mem ? 16'hffff : core_byteenable_line;
		end

endmodule
