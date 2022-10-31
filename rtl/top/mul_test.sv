`timescale 1 ns / 1 ps

module mul_test
#(parameter U=32)
(
    input logic[U - 1:0]	a,		// primer sumando
							b,		// segundo sumando
	input logic[U - 1:0]	c_hi,	// parte más significativa de c
							c_lo,	// parte menos significativa de c
	input logic				c_size,	// 1 si c es de 2 words, cualquier otro valor si c es de 1 word
							clk,	// clock, ya que es una máquina de estados
							rst,	// reset
							add,		// 1 si c se suma
							sig,		// 1 si a y b son signed
							q_size,	// 1 si q es de 2 words, cualquier otro valor si es de 1 word
							start,	// 1 indica que se inicie la multiplicacion

	output  logic [U - 1:0] q_hi,	// parte más significativa del resultado
	output  logic [U - 1:0] q_lo,	// parte menos significativa del resultado
	output  logic [2*U-1:0] result,
	output  logic 			n,		// no hay C ni V, ya que se dejan unaffected
							z,
							q_sig,	// 1 si q es signed, cualquier otro valor si es unsigned
							rdy		// 1 cuando la multiplicación está lista


);
    core_mul #(.U(U)) DUT (.*);

endmodule



