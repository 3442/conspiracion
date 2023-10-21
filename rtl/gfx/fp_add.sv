`include "gfx/gfx_defs.sv"

module fp_add
(
	input  logic clk,
	             rst_n,

	input  logic start,
	input  fp    a,
	             b,

	output logic done,
	output fp    q
);

	pipelined_flow #(.STAGES(`FP_ADD_STAGES)) stages
	(
		.*
	);

`ifndef VERILATOR
	ip_fp_add ip_add
	(
		.areset(0),
		.*
	);
`endif

endmodule
