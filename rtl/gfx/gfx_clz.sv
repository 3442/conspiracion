/* Implementación en árbol de count leading zeros (CLZ).
 * WIDTH debe ser una potencia de 2.
 */
module gfx_clz
#(int WIDTH = 0)
(
	input  logic                  clk,

	input  logic[WIDTH - 1:0]     value,
	output logic[$clog2(WIDTH):0] clz
);

	genvar i;
	generate
		if (WIDTH <= 1) begin
			always_ff @(posedge clk)
				clz <= !value;
		end else if (WIDTH == 2) begin
			always_ff @(posedge clk)
				unique case (value)
					2'b00: clz <= 2'b10;
					2'b01: clz <= 2'b01;
					2'b10: clz <= 2'b00;
					2'b11: clz <= 2'b00;
				endcase
		end else if (WIDTH == 4) begin
			// Eficiente en FPGAs con 4-LUTs
			always_ff @(posedge clk)
				if (value[3])
					clz <= 3'b000;
				else if (value[2])
					clz <= 3'b001;
				else if (value[1])
					clz <= 3'b010;
				else if (value[0])
					clz <= 3'b011;
				else
					clz <= 3'b100;
		end else begin
			logic msb_right;
			logic[$clog2(WIDTH) - 1:0] clz_left, clz_right;
			logic[$clog2(WIDTH) - 2:0] tail_right;

			assign {msb_right, tail_right} = clz_right;

			gfx_clz #(WIDTH / 2) left
			(
				.clk(clk),
				.clz(clz_left),
				.value(value[WIDTH - 1:WIDTH / 2])
			);

			gfx_clz #(WIDTH / 2) right
			(
				.clk(clk),
				.clz(clz_right),
				.value(value[WIDTH / 2 - 1:0])
			);

			always_ff @(posedge clk)
				if (clz_left[$clog2(WIDTH) - 1])
					clz <= {msb_right, ~msb_right, tail_right};
				else
					clz <= {1'b0, clz_left};
		end
	endgenerate

endmodule
