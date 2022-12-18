`include "core/uarch.sv"

module core_porch
(
	input  logic       clk,
	                   rst_n,
	                   flush,
	                   stall,
	input  psr_flags   flags,

	input  word        fetch_insn,
	input  logic       fetch_nop,
	                   fetch_abort,
	input  ptr         fetch_insn_pc,
	                   fetch_head,
	input  insn_decode fetch_dec,

	output word        insn,
	output ptr         insn_pc,
	output insn_decode dec,
	output logic       abort
);

	logic execute, conditional, undefined, nop;
	insn_decode hold_dec;

	//FIXME: User mode puede hacer msr o mcr y saltare cualquier límite de seguridad

	always_comb begin
		dec = hold_dec;
		dec.ctrl.nop = nop;
		dec.ctrl.execute = !flush && dec.ctrl.execute && execute && !nop && !abort;
		dec.ctrl.undefined = !flush && (dec.ctrl.undefined || undefined);
		dec.ctrl.conditional = !flush && (dec.ctrl.conditional || conditional);
	end

	core_porch_conds conds
	(
		.*
	);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			nop <= 0; // Even though it is a NOP
			insn <= `NOP;
			abort <= 0;
			insn_pc <= 0;
			hold_dec <= {$bits(hold_dec){1'b0}};
		end else if(flush || !stall) begin
			nop <= flush ? 1 : fetch_nop;
			insn <= flush ? `NOP : fetch_insn;
			abort <= flush ? 0 : fetch_abort;
			insn_pc <= flush ? fetch_head : fetch_insn_pc;
			hold_dec <= fetch_dec;
		end

endmodule
