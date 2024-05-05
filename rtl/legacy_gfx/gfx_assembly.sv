`include "gfx/gfx_defs.sv"

module gfx_assembly
(
	input  logic     clk,
	                 rst_n,

	input  lane_word send_data,
	input  lane_mask send_mask,
	input  logic     send_valid,
	output logic     send_ready,

	input  logic     out_ready,
	output logic     out_valid,
	output fp_xyzw   out_vertex_a,
	                 out_vertex_b,
	                 out_vertex_c
);

	localparam SETS_PER_TRI = 6;

	mat4 sets[SETS_PER_TRI];
	logic assemble_next, permit_out;
	lane_mask current_mask, next_mask;
	logic[1:0] out_lane;
	logic[2:0] set_num;

	enum int unsigned
	{
		GET_LANES,
		ASSEMBLE
	} state;

	assign out_valid = permit_out && current_mask[out_lane];
	assign out_vertex_a = sets[0][out_lane];
	assign out_vertex_b = sets[2][out_lane];
	assign out_vertex_c = sets[4][out_lane];

	assign next_mask = current_mask & send_mask;
	assign assemble_next = !current_mask[out_lane] || out_ready;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			state <= GET_LANES;
			set_num <= 0;
			out_lane <= 0;
			permit_out <= 0;
			send_ready <= 1;
			current_mask <= {($bits(current_mask)){1'b1}};
		end else unique case (state)
			GET_LANES:
				if (send_valid) begin
					set_num <= set_num + 1;
					current_mask <= next_mask;

					if (set_num == SETS_PER_TRI - 1) begin
						state <= ASSEMBLE;
						permit_out <= 1;
						send_ready <= 0;
					end

					if (!(|next_mask)) begin
						state <= GET_LANES;
						set_num <= 0;
						current_mask <= {($bits(current_mask)){1'b1}};
					end
				end

			ASSEMBLE:
				if (assemble_next) begin
					out_lane <= out_lane + 1;
					if (&out_lane) begin
						state <= GET_LANES;
						permit_out <= 0;
						send_ready <= 1;
					end
				end
		endcase

	always_ff @(posedge clk)
		unique case (state)
			GET_LANES:
				if (send_valid)
					sets[set_num] <= send_data;

			ASSEMBLE: ;
		endcase

endmodule
