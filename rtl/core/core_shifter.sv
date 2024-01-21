`include "core/uarch.sv"

module core_shifter
#(parameter W=16)
(
	input  shifter_control ctrl,
	input  logic[W - 1:0]  base,
	input  logic[7:0]      shift,
	input  logic           c_in,

	output logic[W - 1:0]  q,
	output logic           c
);

	localparam LOG = $clog2(W);

	logic[W - 1:0] q_no_c, q_shl, q_shr, q_ror;
	logic[W:0] sign_mask;
	logic c_shl, c_shr, c_ror;

	assign sign_mask = {(W + 1){ctrl.sign_extend & base[W - 1]}};
	assign {c_shl, q_shl} = {c_in, base} << shift;
	assign {q_shr, c_shr} = {base, c_in} >> shift | (sign_mask & ~(sign_mask >> shift));

	logic ror_cycle;
	logic[LOG - 1:0] ror_shift;
	logic[2 * W:0] ror_out;

	assign ror_shift = shift[LOG - 1:0];
	assign ror_cycle = |shift[7:LOG] & ~|ror_shift;
	assign ror_out = {base, base, c_in} >> {ror_cycle, ror_shift};
	assign {q_ror, c_ror} = ror_out[W:0];

	always_comb
		if(ctrl.ror)
			{c, q} = {c_ror, q_ror};
		else if(ctrl.shr)
			{c, q} = {c_shr, q_shr[W - 1] | (ctrl.put_carry && c_in && shift != 0), q_shr[W - 2:0]};
		else
			{c, q} = {c_shl, q_shl};

endmodule
