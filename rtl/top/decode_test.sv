`timescale 1 ns / 1 ps
`include "core/decode/isa.sv"
`include "core/uarch.sv"

module decode_test
(
    input  word            insn,
	input  logic           n, z, c, v,

	output datapath_decode ctrl,
	output psr_decode      psr_ctrl,
	output branch_decode   branch_ctrl,
	output snd_decode      snd_ctrl,
	output data_decode     data_ctrl,
	output ldst_decode     ldst_ctrl,
	output mul_decode      mul_ctrl,
	output coproc_decode   coproc_ctrl

);
    psr_flags flags;
	assign flags = {n, z, c, v};

    core_decode DUT (.*);

endmodule