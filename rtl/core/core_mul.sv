`include "core/uarch.sv"

// Realiza la operación a * b + c = q
module core_mul
(
	input  logic clk,      // clock, ya que es una máquina de estados
	             rst_n,

	input  word  a,        // primer sumando
	             b,        // segundo sumando
	             c_hi,     // parte más significativa de c
	             c_lo,     // parte menos significativa de c
	input  logic long_mul, // 1 si c es de 2 words, cualquier otro valor si c es de 1 word
	             add,      // 1 si c se suma
	             sig,      // 1 si a y b son signed
	             start,    // 1 indica que se inicie la multiplicacion

	output word  q_hi,     // parte más significativa del resultado
	             q_lo,     // parte menos significativa del resultado
	output logic n,        // no hay C ni V, ya que se dejan unaffected
	             z,
	             ready     // 1 cuando la multiplicación está lista
);

	logic[1:0] wait_state;
	dword c, q;

	assign ready = !start && wait_state == {$bits(wait_state){1'b0}};
	assign {q_hi, q_lo} = q;
	assign n = long_mul ? q_hi[$bits(q_hi) - 1] : q_lo[$bits(q_lo) - 1];
	assign z = q_lo == 0 && (!long_mul || q_hi == 0);

	//TODO: no está probado cuantos ciclos ocupa esto una vez sintetizado
	//TODO: trivio?
	dsp_mul it
	(
		.clock0(clk),
		.aclr0(0), //TODO: parece ser active-high, así que no puede ir a rst_n
		.ena0(start || !ready),
		.dataa_0(a),
		.datab_0(b),
		.chainin(c),
		.signa(sig),
		.signb(sig),
		.result(q)
	);

	always_comb
		if(!add)
			c = {$bits(c){1'b0}};
		else if(long_mul)
			c = {c_hi, c_lo};
		else
			c = {{$bits(word){sig && c_lo[$bits(c_lo) - 1]}}, c_lo};

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n)
			wait_state <= 0;
		else if(wait_state > {$bits(wait_state){1'b0}})
			wait_state <= wait_state - 1;
		else if(start)
			wait_state <= {$bits(wait_state){1'b1}};

endmodule
