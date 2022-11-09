`include "core/uarch.sv"

module core_reg_file
(
	input  logic     clk,
	                 rst_n,

	input  psr_mode  rd_mode,
	input  reg_num   rd_r,
	input  reg_index wr_index,
	input  logic     wr_enable,
	                 wr_enable_file,
	input  word      wr_value,
	                 wr_current,
	                 pc_word,

	output word      rd_value
);

	// Ver comentario en uarch.sv
	word file[`NUM_GPREGS] /*verilator public*/;
	word rd_actual;
	logic rd_pc, hold_rd_pc, forward;
	reg_index rd_index;

	core_reg_map map_rd
	(
		.r(rd_r),
		.mode(rd_mode),
		.is_pc(rd_pc),
		.index(rd_index)
	);

	assign rd_value = hold_rd_pc ? pc_word : forward ? wr_current : rd_actual;

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			forward <= 0;
			hold_rd_pc <= 0;
		end else begin
			forward <= wr_enable && rd_index == wr_index;
			hold_rd_pc <= rd_pc;

			if(wr_enable_file)
				file[wr_index] <= wr_value;

			rd_actual <= file[rd_index];
		end

endmodule
