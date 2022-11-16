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
	input  logic           ldst_next,
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
		if(cycle.rd_indirect_shift)
			shifter_shift = rd_value_b[7:0];
		else
			shifter_shift = {2'b00, data_shift_imm};

		if(cycle.transfer)
			alu_a = saved_base;
		else if(cycle.exception)
			alu_a = {pc, 2'b00};
		else
			alu_a = rd_value_a;

		if(cycle.rd_indirect_shift || cycle.with_shift)
			alu_b = saved_base;
		else if(cycle.transfer)
			alu_b = mem_offset;
		else if(data_snd_is_imm)
			alu_b = {{20{1'b0}}, data_imm};
		else
			alu_b = rd_value_b;
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			alu <= {$bits(alu){1'b0}};
			c_in <= 0;
			shifter <= {$bits(shifter){1'b0}};
			data_imm <= {$bits(data_imm){1'b0}};
			saved_base <= 0;
			data_shift_imm <= {$bits(data_shift_imm){1'b0}};
			data_snd_is_imm <= 0;
			data_snd_shift_by_reg <= 0;
		end else if(next_cycle.issue) begin
			alu <= dec.data.op;
			c_in <= flags.c;

			data_imm <= dec.snd.imm;
			data_shift_imm <= dec.snd.shift_imm;
			data_snd_is_imm <= dec.snd.is_imm;
			data_snd_shift_by_reg <= dec.snd.shift_by_reg;

			shifter.shr <= dec.snd.shr;
			shifter.ror <= dec.snd.ror;
			shifter.put_carry <= dec.snd.put_carry;
			shifter.sign_extend <= dec.snd.sign_extend;
		end else if(next_cycle.rd_indirect_shift) begin
			saved_base <= rd_value_b;
			data_snd_shift_by_reg <= 0;
		end else if(next_cycle.with_shift) begin
			c_in <= c_shifter;
			saved_base <= q_shifter;
		end else if(next_cycle.transfer) begin
			if(ldst_next)
				saved_base <= q_alu;
		end else if(next_cycle.exception) begin
			alu <= `ALU_ADD;
			data_imm <= 12'd4;
			data_snd_is_imm <= 1;
		end

endmodule
