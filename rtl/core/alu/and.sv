module core_alu_and
#(parameter W=16)
(
	input  logic[W - 1:0] a,
	                      b,

	output logic[W - 1:0] q
);

	assign q = a & b;

endmodule
