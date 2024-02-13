`include "core/uarch.sv"

module core_control_issue
(
	input  logic       clk,
	                   rst_n,

	input  logic       halt,
	                   irq,

	input  insn_decode dec,
	input  ptr         insn_pc,
	input  logic       issue_abort,

	input  ctrl_cycle  next_cycle,
	input  logic       next_bubble,

`ifdef VERILATOR
	input  word        insn,
`endif

	output logic       issue,
	                   undefined,
	                   prefetch_abort,
	output ptr         pc,
	                   pc_visible,
	                   next_pc_visible
);

	logic valid;

`ifdef VERILATOR
	word bh0 /*verilator public*/,
	     bh1 /*verilator public*/,
	     bh2 /*verilator public*/,
	     bh3 /*verilator public*/;
`endif

	assign valid = !next_bubble && !halt;
	assign issue = next_cycle.issue && dec.ctrl.execute && valid;
	assign next_pc_visible = insn_pc + 2;

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			pc <= 0;
			undefined <= 0;
			pc_visible <= 2;
			prefetch_abort <= 0;

`ifdef VERILATOR
			bh0 <= 0;
			bh1 <= 0;
			bh2 <= 0;
			bh3 <= 0;
`endif
		end else if(next_cycle.issue) begin
			if(valid) begin
				undefined <= dec.ctrl.undefined;
				prefetch_abort <= issue_abort;

`ifdef VERILATOR
				if(dec.ctrl.undefined && !issue_abort)
					$display("[core] undefined insn: [0x%08x] %08x", insn_pc << 2, insn);
`endif
			end

			pc <= insn_pc;
			pc_visible <= next_pc_visible;

`ifdef VERILATOR
			if(insn_pc != pc && insn_pc != pc + 1 && bh0 != {pc, 2'b00}) begin
				bh0 <= {pc, 2'b00};
				bh1 <= bh0;
				bh2 <= bh1;
				bh3 <= bh2;
			end
`endif
		end

endmodule
