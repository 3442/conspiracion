module core_mul_mul // TODO: cambiar nombre a solo core_mul, ya que solo va a haber una operación para esto
#(parameter W=32)
(
	input   logic[W - 1:0]      a,
                                b,
    input   logic               clk,

	output  logic[(W*2) - 1:0]  q,  // TODO: cambiar a dos salidas de tamaño de 1 word, independientemente de W. se les puede llamar q_hi y q_lo a las dos partes de la respuesta
	output  logic               z,  // no hay C ni V, ya que se dejan unaffected
                                n
    
    //! TODO:
    //! como es una máquina de estados, es necesario tener también:
    //!     Entradas:
    //!         logic[w-1:0] c_hi   // ya que puede ser a * b + c
    //!         logic[w-1:0] c_lo   // ya que puede ser a * b + c   //  se necesitan un hi y un lo porque SMLAL lo requiere
    //!         logic c_big         // ya que puede ser de 32bits o 64bits
    //!         logic add           // ya que se tiene que avisar si se va a sumar c o no
    //!         indicar cuando se inicia la multiplicación en la máquina de estados
    //!         si la operación es signed o unsigned
    //!         logic double_word   // si la salida es de tamaño word o double word
    //!     Salidas:
    //!         indicar en qué ciclo la multiplicación está lista       // ya que la multiplicación es de ciclos
    //!                                                                 // variables
    //! hay que definit un protocolo de cómo se usa este módulo
    //!     Por ejemplo:
    //!         se levanta rdy en algún momento, pero qué pasa al ciclo siguiente? se mantiene o se baja? qué sucede?
    //!         es capaz que se soporte que se haga un ready y un start? esto se define en este módulo, para que contro lo use
    //!         qué pasa si la salida es signed?
    //!         es necesario que las señales de entrada se mantengan constantes durante los ciclos?
);

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
