`include "core/uarch.sv"
`include "core/decode/isa.sv"

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

	logic c, v, c_add, c_sub, c_rsb, v_add, v_sub, v_rsb;
	logic[W - 1:0] not_b, q_add, q_sub, q_rsb, q_and, q_bic, q_orr, q_xor;

	assign not_b = ~b;

	core_alu_add #(.W(W), .SUB(0)) op_add
	(
		.q(q_add),
		.c(c_add),
		.v(v_add),
		.c_in(c_in && !op `FIELD_ALUOP_ADD_CMN && op `FIELD_ALUOP_ADD_NOTCMN_ADC),
		.*
	);

	core_alu_add #(.W(W), .SUB(1)) op_sub
	(
		.q(q_sub),
		.c(c_sub),
		.v(v_sub),
		.c_in(c_in && op `FIELD_ALUOP_SUB_SBC),
		.*
	);

	core_alu_add #(.W(W), .SUB(1)) op_rsb
	(
		.a(b),
		.b(a),
		.q(q_rsb),
		.c(c_rsb),
		.v(v_rsb),
		.c_in(c_in && op `FIELD_ALUOP_RSB_RSC),
		.*
	);

	core_alu_and #(.W(W)) op_and
	(
		.q(q_and),
		.*
	);

	core_alu_and #(.W(W)) op_bic
	(
		.b(not_b),
		.q(q_bic),
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
			`ALU_ADD, `ALU_ADC, `ALU_CMN:
				q = q_add;

			`ALU_SUB, `ALU_SBC, `ALU_CMP:
				q = q_sub;

			`ALU_RSB, `ALU_RSC:
				q = q_rsb;

			`ALU_AND, `ALU_TST:
				q = q_and;

			`ALU_BIC:
				q = q_bic;

			`ALU_EOR, `ALU_TEQ:
				q = q_xor;

			`ALU_ORR:
				q = q_orr;

			`ALU_MOV:
				q = b;

			`ALU_MVN:
				q = not_b;
		endcase

		v = 1'bx;
		unique case(op)
			`ALU_AND, `ALU_EOR, `ALU_TST, `ALU_TEQ, `ALU_ORR, `ALU_MOV, `ALU_BIC, `ALU_MVN:
				c = c_in;

			`ALU_ADD, `ALU_ADC, `ALU_CMN: begin
				c = c_add;
				v = v_add;
			end

			`ALU_SUB, `ALU_SBC, `ALU_CMP: begin
				c = c_sub;
				v = v_sub;
			end

			`ALU_RSB, `ALU_RSC: begin
				c = c_rsb;
				v = v_rsb;
			end
		endcase

		unique case(op)
			`ALU_AND, `ALU_EOR, `ALU_TST, `ALU_TEQ, `ALU_ORR, `ALU_MOV, `ALU_BIC, `ALU_MVN:
				v_valid = 0;

			`ALU_SUB, `ALU_RSB, `ALU_ADD, `ALU_ADC, `ALU_SBC, `ALU_RSC, `ALU_CMP, `ALU_CMN:
				v_valid = 1;
		endcase
	end

	assign nzcv = {q[W - 1], q == 0, c, v};

endmodule
