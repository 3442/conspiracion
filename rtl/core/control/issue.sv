`include "core/uarch.sv"

module core_control_issue
(
	input  logic           clk,

	input  datapath_decode dec,
	input  ptr             fetch_insn_pc,

	input  ctrl_cycle      next_cycle,
	input  logic           next_bubble,

`ifdef VERILATOR
	input  word            insn,
`endif

	output logic           issue,
	                       undefined,
	output ptr             pc,
	                       pc_visible,
	                       next_pc_visible
);

	assign issue = next_cycle == ISSUE && dec.execute && !next_bubble;
	assign next_pc_visible = fetch_insn_pc + 2;

	always_ff @(posedge clk)
		if(next_cycle == ISSUE) begin
			undefined <= dec.undefined;

`ifdef VERILATOR
			if(dec.undefined)
				$display("[core] undefined insn: [0x%08x] %08x", fetch_insn_pc << 2, insn);
`endif

			pc <= fetch_insn_pc;
			pc_visible <= next_pc_visible;
		end

	initial begin
		pc = 0;
		pc_visible = 2;
		undefined = 0;
	end

endmodule
