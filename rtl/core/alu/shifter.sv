`include "core/uarch.sv"

module core_alu_shifter
#(parameter W=16)
(
	input  alu_control    ctrl,
	input  logic[W - 1:0] base,
	input  logic[7:0]     shift,
	input  logic          c_in,

	output logic[W - 1:0] b,
	output logic          c
);

	logic [W - 1:0] b_no_c, b_shl, b_shr, b_ror;
	logic [W:0] sign_mask;
	logic c_shl, c_shr;

	assign sign_mask = {(W + 1){ctrl.sign_extend & base[W - 1]}};
	assign {c_shl, b_shl} = {c_in, base} << shift;
	assign {b_shr, c_shr} = {base, c_in} >> shift | ~(sign_mask >> shift);
	assign b_ror = b_shr | base << (W - shift);

	assign b = {b_no_c[W - 1] | (ctrl.put_carry & c_in), b_no_c[W - 2:0]};
	assign c = ctrl.shr | ctrl.ror ? c_shr : c_shl;

	always_comb
		if(ctrl.ror)
			b = b_ror;
		else if(ctrl.shr)
			b = {b_shr[W - 1] | (ctrl.put_carry & c_in), b_shr[W - 2:0]};
		else
			b = b_shl;

endmodule
