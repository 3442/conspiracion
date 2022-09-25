module alu_shl
#(parameter W=16)
(
	input  logic[W - 1:0] a,
	                      b,
	output logic[W - 1:0] q,
	output logic          c
);

	assign {c, q} = {1'b0, a} << b;

endmodule
