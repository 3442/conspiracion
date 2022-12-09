`include "core/uarch.sv"

module core_control_coproc
(
	input  logic         clk,
	                     rst_n,

	input  insn_decode   dec,
	input  word          coproc_read,

	input  ctrl_cycle    next_cycle,
	input  logic         issue,

	output logic         coproc,
	output word          coproc_wb,
	output coproc_decode coproc_ctrl
);

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			coproc <= 0;
			coproc_wb <= 0;
			coproc_ctrl <= {$bits(coproc_ctrl){1'b0}};
		end else if(next_cycle.issue && issue) begin
			coproc <= dec.ctrl.coproc;
			coproc_ctrl <= dec.coproc;
		end else if(next_cycle.coproc) begin
			coproc <= 0;
			coproc_wb <= coproc_read;
		end

endmodule
