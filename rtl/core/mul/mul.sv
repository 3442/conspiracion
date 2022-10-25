module core_mul
#(parameter W=32)
(   // realiza la operación a * b + c = q
	input logic[W - 1:0]	a,		// primer sumando
							b,		// segundo sumando
	input logic[W - 1:0]	c_hi,	// parte más significativa de c
							c_lo,	// parte menos significativa de c
	input logic				c_size,	// si es 1, c es de 2 words, si es 0, c es de 1 word
							clk,	// clock, ya que es una máquina de estados
							add		// si es 1, c se suma. si es 0, no se suma
							sig		// es 1 si a y b son signed, es 0 si son unisgned
							q_size	// si es 1, q es de 2 words, si es 0, q es de 1 word
							start	// si es 1, se inicia la multiplicacion

	output  word    q_hi,	// parte más significa tiva del resultado
	output  word    q_lo,	// parte menos significativa del resultado
	output  logic   z,
					n,		// no hay C ni V, ya que se dejan unaffected
					q_sig	// si es 1, 1 es signed, es 0 si es unsigned
					rdy		// si es 1, la multiplicación está lista
	
	//*Se asume lo siguiente:
	//	- Las señales de entrada son constantes desde el instante en el que start es 1 hasta que rdy sea 1
	//	- El valor de start puede cambiar durante la multiplicación, pero va a ser ignorado hasta que rdy sea 1
	//	- El valor de q es UNPREDICTABLE hasta que rdy sea 1
	//	- Las condiciones para iniciar una multiplicación son que rdy sea 1 y start sea 1
	//	- rdy solo no es 1 mientras la multiplicación se está realizando
);

	//! TODO:
	//! Testear que el algoritmo sirva bien @julian
	logic[(W*2):0] booth;
	logic[1:0] Q; 
	logic[W-1:0] A, B;
	logic[W - 1:0] counter;

	initial begin
		booth = { W{1'b0}, b, 0 }
		Q = booth[1:0];
		A = booth[(W*2):W];
		B = a;
		counter = W;
	end

always@(posedge clk) begin
		A = booth[(W*2):W];

		unique case(Q)
			2'b01:
				booth[(W*2):W] = A + B;

			2'b10: 
				booth[(W*2):W] = A - B;
			
			// 2'b11 o 2'b00:
			default: ;
				
		endcase

		booth >>> 1;
		counter = counter - 1;

	always_comb
		if(counter == 0) begin
			q = booth[(W*2):1]
		end
	end
endmodule
