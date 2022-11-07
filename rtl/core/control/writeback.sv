`include "core/uarch.sv"

module core_control_writeback
(
	input  logic           clk,

	input  datapath_decode dec,
	input  psr_decode      dec_psr,
	input  data_decode     dec_data,

	input  ctrl_cycle      cycle,
	                       next_cycle,
	input  word            saved_base,
	                       mem_data_rd,
	                       vector,
	                       q_alu,
	input  psr_flags       alu_flags,
	input  reg_num         ra,
	                       popped,
	input  logic           pop_valid,
	                       issue,
	                       mem_ready,
	                       mem_write,

	output reg_num         rd,
	                       final_rd,
	output logic           writeback,
	                       final_writeback,
	                       update_flags,
	                       final_update_flags,
	output word            wr_value,
	output psr_flags       wb_alu_flags
);

	always_ff @(posedge clk) begin
		wb_alu_flags <= alu_flags;

		unique0 case(next_cycle)
			TRANSFER:
				if(mem_ready)
					rd <= final_rd;

			ISSUE, BASE_WRITEBACK:
				rd <= final_rd;

			EXCEPTION:
				rd <= `R15;
		endcase

		unique0 case(next_cycle)
			ISSUE:
				if(issue)
					final_rd <= dec_data.rd;

			TRANSFER:
				if((cycle != TRANSFER || mem_ready) && pop_valid)
					final_rd <= popped;

			BASE_WRITEBACK:
				final_rd <= ra;

			EXCEPTION:
				final_rd <= `R14;
		endcase

		writeback <= 0;
		unique0 case(next_cycle)
			ISSUE:
				writeback <= final_writeback;

			TRANSFER:
				writeback <= mem_ready && !mem_write;

			BASE_WRITEBACK:
				writeback <= !mem_write;

			EXCEPTION:
				writeback <= 1;
		endcase

		unique0 case(next_cycle)
			ISSUE:
				final_writeback <= issue && dec.writeback;

			EXCEPTION:
				final_writeback <= 1;
		endcase

		unique case(cycle)
			TRANSFER:       wr_value <= mem_data_rd;
			BASE_WRITEBACK: wr_value <= saved_base;
			default:        wr_value <= q_alu;
		endcase

		update_flags <= 0;
		unique0 case(next_cycle)
			ISSUE:
				update_flags <= final_update_flags;

			EXCEPTION:
				final_update_flags <= 0;
		endcase

		unique0 case(next_cycle)
			ISSUE:
				final_update_flags <= issue && dec_psr.update_flags;

			EXCEPTION:
				final_update_flags <= 0;
		endcase

		unique0 case(next_cycle)
			TRANSFER:
				if(mem_ready)
					wr_value <= mem_data_rd;

			BASE_WRITEBACK:
				wr_value <= mem_data_rd;

			EXCEPTION:
				wr_value <= vector;
		endcase
	end

	initial begin
		rd = 0;
		final_rd = 0;

		writeback = 0;
		final_writeback = 0;

		update_flags = 0;
		final_update_flags = 0;

		wr_value = 0;
		wb_alu_flags = {$bits(wb_alu_flags){1'b0}};
	end

endmodule
