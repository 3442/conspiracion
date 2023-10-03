`include "cache/defs.sv"

module cache_offsets
(
	input  addr_offset core_offset,		// El offset es un input pero no un output porque se mapea
	input  word_be     core_byteenable,
	input  word        core_writedata,
	input  line        core_readdata_line,
	                   data_rd,

	output line        core_data_wr,
	                   core_writedata_line,
	output word        core_readdata,	// Readdata pasa de ser una line en el input a una word por el offset
	output line_be     core_byteenable_line
);
	// Simplificar offset, para que sea transparente para la cache
	line line_mask;

	// El byteenable se utiliza para leer o escribir en cache algo diferente a una word
	word be_extend, mask3, mask2, mask1, mask0;
	word_be be3, be2, be1, be0;

	assign core_writedata_line = {4{core_writedata}};
	assign core_byteenable_line = {be3, be2, be1, be0};

	// Concatenar para extender a una word ([31:0]) según el valor de byteenable que es [3:0]
	assign be_extend = {{8{core_byteenable[3]}}, {8{core_byteenable[2]}},
	                    {8{core_byteenable[1]}}, {8{core_byteenable[0]}}};

	assign line_mask = {mask3, mask2, mask1, mask0};		// Máscara para toda la línea
	assign core_data_wr = (core_writedata_line & line_mask) | (data_rd & ~line_mask);

	always_comb begin
		mask3 = 0;
		mask2 = 0;
		mask1 = 0;
		mask0 = 0;

		be3 = 0;
		be2 = 0;
		be1 = 0;
		be0 = 0;

		// Elegir la word que se va a retornar según el valor de offset 
		unique case (core_offset)
			2'b00: begin
				be0 = core_byteenable;
				mask0 = be_extend;
				core_readdata = core_readdata_line[31:0];
			end

			2'b01: begin
				be1 = core_byteenable;
				mask1 = be_extend;
				core_readdata = core_readdata_line[63:32];
			end

			2'b10: begin
				be2 = core_byteenable;
				mask2 = be_extend;
				core_readdata = core_readdata_line[95:64];
			end

			2'b11: begin
				be3 = core_byteenable;
				mask3 = be_extend;
				core_readdata = core_readdata_line[127:96];
			end
		endcase
	end

endmodule
