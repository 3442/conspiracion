`include "core/uarch.sv"

module core_control_mux
(
	input  logic       clk,

	input  word        rd_value_a,
	                   rd_value_b,

	input  ctrl_cycle  cycle,
	input  logic       data_snd_is_imm,
	input  logic[5:0]  data_shift_imm,
	input  logic[11:0] data_imm,
	input  ptr         pc,
	input  word        saved_base,
	                   mem_offset,

	output word        alu_a,
	                   alu_b,
	output logic[7:0]  shifter_shift
);

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

endmodule
