`include "core/uarch.sv"

module core_alu
#(parameter W=16)
(
	input  alu_op         op,
	input  logic[W - 1:0] a,
	                      b,
	input  logic          c_in,

	output logic[W - 1:0] q,
	output psr_flags      nzcv,
	output logic          v_valid
);

	logic c, v, swap, sub, and_not, c_add, v_add;
	logic[W - 1:0] swap_a, swap_b, not_b, c_in_add, q_add, q_and, q_orr, q_xor;

	assign swap_a = swap ? b : a;
	assign swap_b = swap ? a : b;
	assign not_b = ~b;

	core_alu_add #(.W(W)) op_add
	(
		.a(swap_a),
		.b(sub ? -swap_b : swap_b),
		.c_in(c_in_add),
		.q(q_add),
		.c(c_add),
		.v(v_add),
		.*
	);

	core_alu_and #(.W(W)) op_and
	(
		.b(and_not ? not_b : b),
		.q(q_and),
		.*
	);

	core_alu_orr #(.W(W)) op_orr
	(
		.q(q_orr),
		.*
	);

	core_alu_xor #(.W(W)) op_xor
	(
		.q(q_xor),
		.*
	);

	always_comb begin
		unique case(op)
			`ALU_ADD, `ALU_ADC, `ALU_CMN, `ALU_CMP, `ALU_SUB, `ALU_SBC:
				swap = 0;

			`ALU_RSB, `ALU_RSC:
				swap = 1;

			default:
				swap = 1'bx;
		endcase

		unique case(op)
			`ALU_ADD, `ALU_CMN, `ALU_ADC:
				sub = 0;

			`ALU_SUB, `ALU_CMP, `ALU_SBC, `ALU_RSB, `ALU_RSC:
				sub = 1;

			default:
				sub = 1'bx;
		endcase

		unique case(op)
			`ALU_ADD, `ALU_CMN, `ALU_CMP, `ALU_SUB, `ALU_RSB:
				c_in_add = 0;

			`ALU_ADC:
				c_in_add = {{(W - 1){1'b0}}, c_in};

			`ALU_SBC, `ALU_RSC:
				c_in_add = {{(W - 1){~c_in}}, ~c_in};

			default:
				c_in_add = {W{1'bx}};
		endcase

		unique case(op)
			`ALU_AND, `ALU_TST:
				and_not = 0;

			`ALU_BIC:
				and_not = 1;

			default:
				and_not = 1'bx;
		endcase

		unique case(op)
			`ALU_SUB, `ALU_RSB, `ALU_ADD, `ALU_ADC, `ALU_SBC, `ALU_RSC, `ALU_CMP, `ALU_CMN:
				q = q_add;

			`ALU_AND, `ALU_TST, `ALU_BIC:
				q = q_and;

			`ALU_EOR, `ALU_TEQ:
				q = q_xor;

			`ALU_ORR:
				q = q_orr;

			`ALU_MOV:
				q = b;

			`ALU_MVN:
				q = not_b;
		endcase

		unique case(op)
			`ALU_AND, `ALU_EOR, `ALU_TST, `ALU_TEQ, `ALU_ORR, `ALU_MOV, `ALU_BIC, `ALU_MVN: begin
				c = c_in;
				v = 1'bx;
				v_valid = 0;
			end

			`ALU_SUB, `ALU_RSB, `ALU_ADD, `ALU_ADC, `ALU_SBC, `ALU_RSC, `ALU_CMP, `ALU_CMN: begin
				c = c_add;
				v = v_add;
				v_valid = 1;
			end
		endcase
	end

	assign nzcv = {q[W - 1], ~|q, c, v};

endmodule
