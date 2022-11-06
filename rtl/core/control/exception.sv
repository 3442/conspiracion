`include "core/uarch.sv"

module core_control_exception
(
	input  logic clk,

	input  logic undefined,

	output word  vector,
	output logic exception
);

	logic high_vectors;
	logic[2:0] vector_offset;

	assign exception = undefined; //TODO
	assign high_vectors = 0; //TODO
	assign vector = {{16{high_vectors}}, 11'b0, vector_offset, 2'b00};

	always_comb
		vector_offset = 3'b001; //TODO

	//TODO: spsr_<mode> = cpsr
	//TODO: actualizar modo
	//TODO: deshabilitar IRQs/FIQs dependiendo de modo
	//TODO: Considerar que data abort usa + 8, no + 4

endmodule
