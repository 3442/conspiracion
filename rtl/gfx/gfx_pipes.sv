module gfx_pipes
#(parameter WIDTH=0, DEPTH=0)
(
	input  logic              clk,

	input  logic[WIDTH - 1:0] in,
	input  logic              stall,

	output logic[WIDTH - 1:0] out
);

	logic[WIDTH - 1:0] pipes[DEPTH];

	assign out = pipes[DEPTH - 1];

	always_ff @(posedge clk)
		if (!stall) begin
			pipes[0] <= in;

			/* Esto tiene que ir así porque Verilator no soporta <= en for
			 * loops a las que no logre hacerle unrolling. Nótese que el
			 * orden de iteración descendiente es necesario porque estamos
			 * usando un blocking assignment dentro de always_ff.
			 */
			for (integer i = DEPTH - 1; i > 0; --i)
				pipes[i] = pipes[i - 1];
		end

endmodule
