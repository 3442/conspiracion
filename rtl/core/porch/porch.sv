`include "core/uarch.sv"

module core_porch
(
	input  logic       clk,
	                   flush,
	                   stall,
	input  psr_flags   flags,

	input  word        fetch_insn,
	input  ptr         fetch_insn_pc,
	input  insn_decode fetch_dec,

	output word        insn,
	output ptr         insn_pc,
	output insn_decode dec
);

	logic execute, conditional, undefined;
	insn_decode nop, hold_dec;

	core_porch_conds conds
	(
		.*
	);

	assign nop.ctrl.execute = 0;
	assign nop.ctrl.undefined = 0;
	assign nop.ctrl.conditional = 0;

	always_comb begin
		dec = hold_dec;
		dec.ctrl.execute = !flush && dec.ctrl.execute && execute;
		dec.ctrl.undefined = !flush && (dec.ctrl.undefined || undefined);
		dec.ctrl.conditional = !flush && (dec.ctrl.conditional || conditional);
	end

	always @(posedge clk)
		if(!stall) begin
			insn <= fetch_insn;
			hold_dec <= fetch_dec;

			if(!flush)
				insn_pc <= fetch_insn_pc;
		end

	initial begin
		insn = `NOP;
		insn_pc = 0;
		hold_dec = nop;
	end

endmodule
