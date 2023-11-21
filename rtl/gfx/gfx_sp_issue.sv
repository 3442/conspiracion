`include "gfx/gfx_defs.sv"

module gfx_sp_issue
(
	input  logic     clk,
	                 rst_n,

	input  insn_deco deco,
	input  logic     deco_valid,
	output logic     deco_ready,

	output vreg_num  rd_a_reg,
	                 rd_b_reg,

	input  logic     stream_issue_ready,
	output logic     stream_issue_valid,

	input  logic     combiner_issue_ready,
	output logic     combiner_issue_valid,

	input  logic     shuffler_issue_ready,
	output logic     shuffler_issue_valid,

	input  logic     wr,
	input  vreg_num  wr_reg
);

	/* Esto podría ser fully pipelined, pero no dio tiempo, y en
	* todo caso no haría diferencia debido al pésimo ancho de banda.
	 */

	logic data_hazard, rd_a_hazard, rd_b_hazard, wr_hazard, writing_a, writing_b, writing_dst,
	      busy[`GFX_SP_REG_COUNT];

	enum int unsigned
	{
		IDLE,
		HAZARDS,
		ISSUE,
		WAIT
	} state;

	assign rd_a_reg = deco.src_a;
	assign rd_b_reg = deco.src_b;

	assign wr_hazard = deco.writeback && writing_dst;
	assign rd_a_hazard = deco.read_src_a && writing_a;
	assign rd_b_hazard = deco.read_src_a && writing_b;
	assign data_hazard = rd_a_hazard || rd_b_hazard || wr_hazard;

	assign deco_ready =  (stream_issue_ready && stream_issue_valid)
	                  || (combiner_issue_ready && combiner_issue_valid)
	                  || (shuffler_issue_ready && shuffler_issue_valid);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= IDLE;

			stream_issue_valid <= 0;
			combiner_issue_valid <= 0;
			shuffler_issue_valid <= 0;

			for (integer i = 0; i < `GFX_SP_REG_COUNT; ++i)
				busy[i] <= 0;
		end else begin
			unique case (state)
				IDLE:
					if (deco_valid)
						state <= HAZARDS;

				HAZARDS:
					if (!data_hazard) begin
						state <= ISSUE;
						if (deco.writeback)
							busy[deco.dst] <= 1;
					end

				ISSUE: begin
					state <= WAIT;

					if (deco.ex.stream)
						stream_issue_valid <= 1;

					if (deco.ex.combiner)
						combiner_issue_valid <= 1;

					if (deco.ex.shuffler)
						shuffler_issue_valid <= 1;
				end

				WAIT:
					if (deco_ready) begin
						state <= IDLE;

						stream_issue_valid <= 0;
						combiner_issue_valid <= 0;
						shuffler_issue_valid <= 0;
					end
			endcase

			if (wr)
				busy[wr_reg] <= 0;
		end

	always_ff @(posedge clk) begin
		writing_a <= busy[deco.src_a];
		writing_b <= busy[deco.src_b];
		writing_dst <= busy[deco.dst];
	end

endmodule
