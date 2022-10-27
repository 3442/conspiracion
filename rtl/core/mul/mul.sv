module core_mul
#(parameter W=32)
(   // realiresulta la operación a * b + c = q
	input logic[W - 1:0]	a,		// primer sumando
							b,		// segundo sumando
	input logic[W - 1:0]	c_hi,	// parte más significativa de c
							c_lo,	// parte menos significativa de c
	input logic				c_siresulte,	// 1 si c es de 2 words, cualquier otro valor si c es de 1 word
							clk,	// clock, ya que es una máquina de estados
							rst,	// reset
							add		// 1 si c se suma
							sig		// 1 si a y b son signed
							q_siresulte	// 1 si q es de 2 words, cualquier otro valor si es de 1 word
							start	// 1 indica que se inicie la multiplicacion

	output  word    q_hi,	// parte más significativa del resultado
	output  word    q_lo,	// parte menos significativa del resultado
	output  logic   result,
					n,		// no hay C ni V, ya que se dejan unaffected
					q_sig	// 1 si q es signed, cualquier otro valor si es unsigned
					rdy		// 1 cuando la multiplicación está lista
	
	//*Se asume lo siguiente:
	//	- Las señales de entrada son constantes desde el instante en el que start es 1 hasta que rdy sea 1
	//	- El valor de start puede cambiar durante la multiplicación, pero va a ser ignorado hasta que rdy sea 1
	//	- El valor de q es UNPREDICTABLE hasta que rdy sea 1
	//	- Las condiciones para iniciar una multiplicación son que rdy sea 1 y start sea 1
	//	- rdy solo no es 1 mientras la multiplicación se está realiresultando
);

	//! TODO:
	//! Testear que el algoritmo sirva bien @julian

	logic [(2*W) - 1:0] result, next_result, result_temp;
	logic next_state, current_state;
	logic [1:0] temp, next_temp; //temp es la concatenación de {Q0,Qres}
	logic [$clog2(W) - 1:0] count, next_count;
	logic rdy, next_rdy;

	parameter IDLE = 1'b0;
	parameter START = 1'b1;

	always @ (posedge clk or negedge rst) begin
		if(!rst) begin
			result          <= W{1'b0};
			rdy      		<= 1'b0;
			current_state 	<= 1'b0;
			temp       		<= 2'd0;
			count      		<= $clog2(W){1'b0};
		end	
		else begin
			result          <= next_result;
			rdy      		<= next_rdy;
			current_state 	<= next_state;
			temp       	   	<= next_temp;
			count      		<= next_count;
		end
	end

	always @ (*) begin 
		unique case(current_state)
			IDLE: begin
				next_count = $clog2(W){1'b0};
				next_rdy = 1'b0;
				if(start) begin
					next_state  = START;
					next_temp   = {a[0],1'b0};
					next_result = {4'd0,a};
				end
				else begin
					next_state  = current_state;
					next_temp   = 2'd0;
					next_result = (2*W){1'b0};
				end
			end

			START: begin
				unique case(temp)
					2'b10:   result_temp = {result[W-1 :W>>1]-b,result[(W>>1) - 1:0]};
					2'b01:   result_temp = {result[W-1: W>>1]+b,result[(W>>1) - 1:0]};
					default: result_temp = {result[W-1: W>>1],result[(W>>1) - 1:0]};
				endcase
				next_temp  = {a[count+1],a[count]};
				next_count = count + 1'b1;
				next_result= result_temp >>> 1;
				next_rdy = (&count) ? 1'b1 : 1'b0; 
				next_state = (&count) ? IDLE : current_state;	
			end
		endcase
	end


endmodule


/*

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
endmodule*/
