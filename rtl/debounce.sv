module debounce
(
	input  logic clk,
	             dirty,
	output logic clean
);

	logic last;
	logic[15:0] clean_for;

	always @(posedge clk) begin
		last <= dirty;
		clean_for <= last == dirty ? clean_for + 1 : 0;

		if(&clean_for)
			clean <= last;
	end

	initial begin
		last = 0;
		clean = 0;
		clean_for = 0;
	end

endmodule
