`include "core/uarch.sv"

module core_porch
(
	input  logic       clk,
	                   rst_n,
	                   flush,
	                   stall,
	input  psr_flags   flags,

	input  word        fetch_insn,
	input  ptr         fetch_insn_pc,
	                   fetch_head,
	input  insn_decode fetch_dec,

	output word        insn,
	output ptr         insn_pc,
	output insn_decode dec
);

	logic execute, conditional, undefined;
	insn_decode hold_dec;

	always_comb begin
		dec = hold_dec;
		dec.ctrl.execute = !flush && dec.ctrl.execute && execute;
		dec.ctrl.undefined = !flush && (dec.ctrl.undefined || undefined);
		dec.ctrl.conditional = !flush && (dec.ctrl.conditional || conditional);
	end

	core_porch_conds conds
	(
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			insn <= `NOP;
			insn_pc <= 0;
			hold_dec <= {$bits(hold_dec){1'b0}};
		end else if(flush || !stall) begin
			insn <= flush ? `NOP : fetch_insn;
			insn_pc <= flush ? fetch_head : fetch_insn_pc;
			hold_dec <= fetch_dec;
		end

endmodule