`include "core/uarch.sv"

module core_control_data
(
	input  logic           clk,
	                       rst_n,

	input  insn_decode     dec,
	input  word            rd_value_a,
	                       rd_value_b,
	input  logic           mem_ready,
	input  word            q_alu,
	                       q_shifter,
	input  logic           c_shifter,

	input  ctrl_cycle      cycle,
	                       next_cycle,
	input  ptr             pc,
	input  word            mem_offset,
	input  psr_flags       flags,

	output alu_op          alu,
	output word            alu_a,
	                       alu_b,
	                       saved_base,
	output shifter_control shifter,
	output logic[7:0]      shifter_shift,
	output logic           c_in,
	                       trivial_shift,
	                       data_snd_shift_by_reg
);

	logic data_snd_is_imm;
	logic[5:0] data_shift_imm;
	logic[11:0] data_imm;

	assign trivial_shift = shifter_shift == 0;

	always_comb begin
		unique case(cycle)
			RD_INDIRECT_SHIFT: shifter_shift = rd_value_b[7:0];
			default:           shifter_shift = {2'b00, data_shift_imm};
		endcase

		unique case(cycle)
			TRANSFER:  alu_a = saved_base;
			EXCEPTION: alu_a = {pc, 2'b00};
			default:   alu_a = rd_value_a;
		endcase

		unique case(cycle)
			RD_INDIRECT_SHIFT, WITH_SHIFT:
				alu_b = saved_base;

			TRANSFER:
				alu_b = mem_offset;

			default:
				if(data_snd_is_imm)
					alu_b = {{20{1'b0}}, data_imm};
				else
					alu_b = rd_value_b;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			alu <= {$bits(alu){1'b0}};
			c_in <= 0;
			shifter <= {$bits(shifter){1'b0}};
			data_imm <= {$bits(data_imm){1'b0}};
			data_shift_imm <= {$bits(data_shift_imm){1'b0}};
			data_snd_is_imm <= 0;
			data_snd_shift_by_reg <= 0;
		end else unique case(next_cycle)
			ISSUE: begin
				alu <= dec.data.op;
				c_in <= flags.c;

				data_snd_is_imm <= dec.snd.is_imm;
				data_snd_shift_by_reg <= dec.snd.shift_by_reg;
				data_imm <= dec.snd.imm;
				data_shift_imm <= dec.snd.shift_imm;

				shifter.shr <= dec.snd.shr;
				shifter.ror <= dec.snd.ror;
				shifter.put_carry <= dec.snd.put_carry;
				shifter.sign_extend <= dec.snd.sign_extend;
			end

			RD_INDIRECT_SHIFT: begin
				saved_base <= rd_value_b;
				data_snd_shift_by_reg <= 0;
			end

			WITH_SHIFT: begin
				c_in <= c_shifter;
				saved_base <= q_shifter;
			end

			TRANSFER:
				if(cycle != TRANSFER || mem_ready)
					saved_base <= q_alu;

			EXCEPTION: begin
				alu <= `ALU_ADD;
				data_imm <= 12'd4;
				data_snd_is_imm <= 1;
			end
		endcase

endmodule
