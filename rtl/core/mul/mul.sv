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
							sig		// si la suma es signed o unisgned
							q_size	// si es 1, q es de 2 words, si es 0, q es de 1 word

	output  word    q_hi,	// parte más significa tiva del resultado
	output  word    q_lo,	// parte menos significativa del resultado
	output  logic   z,
					n,		// no hay C ni V, ya que se dejan unaffected
					rdy		// si es 1, la multiplicación está lista
	
	//! TODO:
	//! hay que definit un protocolo de cómo se usa este módulo
	//!     Por ejemplo:
	//!         se levanta rdy en algún momento, pero qué pasa al ciclo siguiente? se mantiene o se baja? qué sucede?
	//!         es capaz que se soporte que se haga un ready y un start? esto se define en este módulo, para que contro lo use
	//!         qué pasa si la salida es signed?
	//!         es necesario que las señales de entrada se mantengan constantes durante los ciclos?
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
