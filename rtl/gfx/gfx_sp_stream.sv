`include "gfx/gfx_defs.sv"

module gfx_sp_stream
(
	input  logic     clk,
	                 rst_n,

	input  mat4      a,
	input  insn_deco deco,
	input  logic     in_valid,
	output logic     in_ready,

	output wb_op     wb,
	input  logic     wb_ready,
	output logic     wb_valid,

	input  lane_word recv_data,
	input  lane_mask recv_mask,
	input  logic     recv_valid,
	output logic     recv_ready,

	input  logic     send_ready,
	output logic     send_valid,
	output lane_word send_data,
	output lane_mask send_mask
);

	logic active, recv;
	vreg_num wb_reg;

	assign in_ready = !active;
	assign recv_ready = active && recv && wb_ready;

	assign wb_valid = active && recv && recv_valid;
	assign send_valid = active && !recv;

	assign wb.dst = wb_reg;
	assign wb.data = recv_data;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			active <= 0;
			send_mask <= 0;
		end else begin
			if (!active)
				active <= in_valid && (deco.writeback || |send_mask);
			else if (recv)
				active <= !wb_ready || !recv_valid;
			else
				active <= !send_ready;

			if (recv_ready && recv_valid)
				send_mask <= send_mask & recv_mask;

			if (in_ready && in_valid && deco.clear_lanes)
				send_mask <= {($bits(send_mask)){1'b1}};
		end

	always_ff @(posedge clk)
		if (!active) begin
			recv <= deco.writeback;
			wb_reg <= deco.dst;
			send_data <= a;
		end

endmodule
