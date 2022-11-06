`include "core/uarch.sv"

// Realiza la operación a * b + c = q
module core_mul
(
	input  logic clk,      // clock, ya que es una máquina de estados
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

	logic wait_state;
	dword c, q;

	assign ready = wait_state == {$bits(wait_state){1'b0}};
	assign {q_hi, q_lo} = q;
	assign n = long_mul ? q_hi[$bits(q_hi) - 1] : q_lo[$bits(q_lo) - 1];
	assign z = q_lo == 0 && (!long_mul || q_hi == 0);

	dsp_mul ip
	(
		.clock0(clk),
		.aclr0(0), //TODO
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

	always_ff @(posedge clk)
		if(wait_state > {$bits(wait_state){1'b0}})
			wait_state <= wait_state - 1;
		else if(start)
			wait_state <= 1;

	initial
		wait_state = 0;

endmodule
