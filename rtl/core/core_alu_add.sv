module core_alu_add
#
(
	parameter W=16,
	parameter SUB=0
)
(
	input  logic[W - 1:0] a,
	                      b,
	input  logic          c_in,

	output logic[W - 1:0] q,
	output logic          c,
	                      v
);

	logic sgn_a, sgn_b, sgn_q, maybe_v;
	logic[W:0] out;

	/* Quartus infiere dos sumadores si se zero-extendea el cin
	 * para complacer a Verilator, lo cual es malo para Fmax.
	 */
`ifdef VERILATOR
	logic[W:0] ext_carry;
	assign ext_carry = {{W{1'b0}}, c_in};
`else
	logic ext_carry;
	assign ext_carry = c_in;
`endif

	assign v = maybe_v & (sgn_a ^ sgn_q);
	assign {c, q} = out;
	assign {sgn_a, sgn_b, sgn_q} = {a[W - 1], b[W - 1], q[W - 1]};

	generate
		if(SUB) begin
			assign out = {1'b1, a} - {1'b0, b} - ext_carry;
			assign maybe_v = sgn_a ^ sgn_b;
		end else begin
			assign out = {1'b0, a} + {1'b0, b} + ext_carry;
			assign maybe_v = sgn_a ~^ sgn_b;
		end
	endgenerate

endmodule
