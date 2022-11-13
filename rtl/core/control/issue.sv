`include "core/uarch.sv"

module core_control_issue
(
	input  logic       clk,
	                   rst_n,
	                   halt,

	input  insn_decode dec,
	input  ptr         insn_pc,

	input  ctrl_cycle  next_cycle,
	input  logic       next_bubble,

`ifdef VERILATOR
	input  word        insn,
`endif

	output logic       issue,
	                   undefined,
	output ptr         pc,
	                   pc_visible,
	                   next_pc_visible
);

	assign issue = next_cycle == ISSUE && dec.ctrl.execute && !next_bubble && !halt;
	assign next_pc_visible = insn_pc + 2;

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pc <= 0;
			undefined <= 0;
			pc_visible <= 2;
		end else if(next_cycle == ISSUE) begin
			undefined <= dec.ctrl.undefined;

`ifdef VERILATOR
			if(dec.ctrl.undefined)
				$display("[core] undefined insn: [0x%08x] %08x", insn_pc << 2, insn);
`endif

			pc <= insn_pc;
			pc_visible <= next_pc_visible;
		end

endmodule
