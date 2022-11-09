`timescale 1 ns / 1 ps
`include "core/decode/isa.sv"
`include "core/uarch.sv"

module decode_test
(
    input  word        insn,

	output insn_decode dec
);

    core_decode DUT (.*);

endmodule
