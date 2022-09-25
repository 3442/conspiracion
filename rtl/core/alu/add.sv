module core_alu_add
#(parameter W=16)
(
	input  logic[W - 1:0] a,
	                      b,
	                      c_in,

	output logic[W - 1:0] q,
	output logic          c,
	                      v
);

	logic sgn_a, sgn_b, sgn_q;
	assign {sgn_a, sgn_b, sgn_q} = {a[W - 1], b[W - 1], q[W - 1]};

	//TODO: No sirve el carry
	assign {c, q} = {1'b0, a} + {1'b0, b} + {1'b0, c_in};
	assign v = (sgn_a ~^ sgn_b) & (sgn_a ^ sgn_q);

endmodule
