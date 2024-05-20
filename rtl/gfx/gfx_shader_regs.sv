module gfx_shader_regs
import gfx::*;
(
	input  logic               clk,

	       gfx_regfile_io.regs io
);

	// verilator tracing_off

	localparam PC_TABLE_PORTS   = 2;
	localparam MASK_TABLE_PORTS = 2;

	word hold_imm[REGFILE_STAGES], imm_out, read_a_data_sgpr, read_b_data_scalar,
	     read_b_data_sgpr, read_const, read_a_data_vgpr[SHADER_LANES],
	     read_b_data_vgpr[SHADER_LANES], sgpr_out_a, sgpr_out_b;

	group_id mask_read_groups[MASK_TABLE_PORTS], pc_read_groups[PC_TABLE_PORTS];
	word_ptr pc_read[PC_TABLE_PORTS];
	lane_mask mask_read[MASK_TABLE_PORTS];

	logic a_scalar_out, b_is_const_out, b_is_imm_out, b_scalar_out, scalar_rev_out;
	group_id hold_read_group_1, hold_read_group_2;
	sgpr_num hold_read_a_sgpr;
	vgpr_num hold_read_a_vgpr_1, hold_read_a_vgpr_2, hold_read_b_vgpr_1, hold_read_b_vgpr_2;
	logic[REGFILE_STAGES - 1:0] hold_b_is_imm, hold_b_is_const;
	logic[REGFILE_STAGES + 1 - 1:0] hold_scalar_rev;
	logic[REGFILE_STAGES + 2 - 1:0] hold_a_scalar, hold_b_scalar;

	assign io.pc_back = pc_read[0];
	assign io.pc_front = pc_read[1];
	assign pc_read_groups[0] = io.pc_back_group;
	assign pc_read_groups[1] = io.pc_front_group;

	assign io.mask_back = mask_read[0];
	assign io.mask_exec = mask_read[1];
	assign mask_read_groups[0] = io.mask_back_group;
	assign mask_read_groups[1] = io.mask_exec_group;

	assign imm_out = hold_imm[$size(hold_imm) - 1];
	assign a_scalar_out = hold_a_scalar[$bits(hold_a_scalar) - 1];
	assign b_scalar_out = hold_b_scalar[$bits(hold_b_scalar) - 1];
	assign b_is_imm_out = hold_b_is_imm[$bits(hold_b_is_imm) - 1];
	assign b_is_const_out = hold_b_is_const[$bits(hold_b_is_const) - 1];
	assign scalar_rev_out = hold_scalar_rev[$bits(hold_scalar_rev) - 1];

	gfx_shader_table #(.DATA_WIDTH($bits(word_ptr)), .READ_PORTS(PC_TABLE_PORTS)) pc_table
	(
		.clk,
		.read(pc_read),
		.write(io.pc_wb),
		.read_groups(pc_read_groups),
		.write_group(io.pc_wb_group),
		.write_enable(io.pc_wb_write)
	);

	gfx_shader_table #(.DATA_WIDTH($bits(lane_mask)), .READ_PORTS(MASK_TABLE_PORTS)) mask_table
	(
		.clk,
		.read(mask_read),
		.write(io.mask_wb),
		.read_groups(mask_read_groups),
		.write_group(io.mask_wb_group),
		.write_enable(io.mask_wb_write)
	);

	gfx_shader_consts consts
	(
		.clk,
		.num(io.op.b_sgpr),
		.value(read_const)
	);

	gfx_shader_regfile #($bits(group_id) + $bits(sgpr_num)) sgprs
	(
		.clk,

		.read_a_num({hold_read_group_1, hold_read_a_sgpr}),
		.read_b_num({io.op.group, io.op.b_sgpr}),
		.read_a_data(read_a_data_sgpr),
		.read_b_data(read_b_data_sgpr),

		.write(io.sgpr_write.write),
		.write_num({io.sgpr_write.group, io.sgpr_write.sgpr}),
		.write_data(io.sgpr_write.data)
	);

	genvar gi;
	generate
		for (gi = 0; gi < SHADER_LANES; ++gi) begin: vgprs
			gfx_shader_regfile #($bits(group_id) + $bits(vgpr_num)) vgprs
			(
				.clk,

				.read_a_num({hold_read_group_2, hold_read_a_vgpr_2}),
				.read_b_num({hold_read_group_2, hold_read_b_vgpr_2}),
				.read_a_data(read_a_data_vgpr[gi]),
				.read_b_data(read_b_data_vgpr[gi]),

				.write(io.vgpr_write.mask[gi]),
				.write_num({io.vgpr_write.group, io.vgpr_write.vgpr}),
				.write_data(io.vgpr_write.data[gi])
			);
		end
	endgenerate

	always_ff @(posedge clk) begin
		hold_imm[0] <= {{($bits(word) - $bits(io.op.b_imm)){1'b0}}, io.op.b_imm};
		hold_a_scalar[0] <= io.op.a_scalar;
		hold_b_scalar[0] <= io.op.b_scalar;
		hold_b_is_imm[0] <= io.op.b_is_imm;
		hold_b_is_const[0] <= io.op.b_is_const;
		hold_scalar_rev[0] <= io.op.scalar_rev;

		for (int i = 1; i < REGFILE_STAGES; ++i) begin
			hold_imm[i] <= hold_imm[i - 1];
			hold_a_scalar[i] <= hold_a_scalar[i - 1];
			hold_b_scalar[i] <= hold_b_scalar[i - 1];
			hold_b_is_imm[i] <= hold_b_is_imm[i - 1];
			hold_b_is_const[i] <= hold_b_is_const[i - 1];
			hold_scalar_rev[i] <= hold_scalar_rev[i - 1];
		end

		for (int i = REGFILE_STAGES; i < REGFILE_STAGES + 2; ++i) begin
			hold_a_scalar[i] <= hold_a_scalar[i - 1];
			hold_b_scalar[i] <= hold_b_scalar[i - 1];
		end

		hold_scalar_rev[REGFILE_STAGES] <= hold_scalar_rev[REGFILE_STAGES - 1];

		hold_read_a_sgpr <= io.op.a_sgpr;
		hold_read_group_1 <= io.op.group;
		hold_read_group_2 <= hold_read_group_1;

		hold_read_a_vgpr_1 <= io.op.a_vgpr;
		hold_read_a_vgpr_2 <= hold_read_a_vgpr_1;

		hold_read_b_vgpr_1 <= io.op.b_vgpr;
		hold_read_b_vgpr_2 <= hold_read_b_vgpr_1;

		if (b_is_imm_out)
			read_b_data_scalar <= imm_out;
		else if (b_is_const_out)
			read_b_data_scalar <= read_const;
		else
			read_b_data_scalar <= read_b_data_sgpr;

		if (scalar_rev_out) begin
			sgpr_out_a <= read_b_data_scalar;
			sgpr_out_b <= read_a_data_sgpr;
		end else begin
			sgpr_out_a <= read_a_data_sgpr;
			sgpr_out_b <= read_b_data_scalar;
		end

		for (int i = 0; i < SHADER_LANES; ++i) begin
			io.a[i] <= a_scalar_out ? sgpr_out_a : read_a_data_vgpr[i];
			io.b[i] <= b_scalar_out ? sgpr_out_b : read_a_data_vgpr[i];
		end
	end

endmodule

module gfx_shader_consts
import gfx::*;
(
	input  logic    clk,

	input  sgpr_num num,
	output word     value
);

	word hold_out, rom[1 << $bits(sgpr_num)];
	sgpr_num hold_in;

	always_ff @(posedge clk) begin
		value <= hold_out;
		hold_in <= num;
		hold_out <= rom[hold_in];
	end

	initial begin
		rom[0] = 'hffff_ffff; // -1
		rom[1] = 'h7fff_ffff; // 2^31 - 1, útil para abs de fp
		rom[2] = 'h8000_0000; // 2^31, útil para neg de fp
		rom[3] = 'h3f80_0000; // +1.0
		rom[4] = 'hbf80_0000; // -1.0
	end

endmodule

module gfx_shader_regfile
import gfx::*;
#(int DEPTH_LOG = 0)
(
	input  logic                  clk,

	input  logic[DEPTH_LOG - 1:0] read_a_num,
	                              read_b_num,
	output word                   read_a_data,
	                              read_b_data,

	input  logic                  write,
	input  logic[DEPTH_LOG - 1:0] write_num,
	input  word                   write_data
);

	gfx_shader_regfile_port #(DEPTH_LOG) a
	(
		.clk,
		.write,
		.read_num(read_a_num),
		.read_data(read_a_data),
		.write_num,
		.write_data
	);

	gfx_shader_regfile_port #(DEPTH_LOG) b
	(
		.clk,
		.write,
		.read_num(read_b_num),
		.read_data(read_b_data),
		.write_num,
		.write_data
	);

endmodule

module gfx_shader_regfile_port
import gfx::*;
#(int DEPTH_LOG = 0)
(
	input  logic                  clk,

	input  logic[DEPTH_LOG - 1:0] read_num,
	output word                   read_data,

	input  logic                  write,
	input  logic[DEPTH_LOG - 1:0] write_num,
	input  word                   write_data
);

	word file[1 << DEPTH_LOG], hold_read_data, hold_write_data;
	logic hold_write;
	logic[DEPTH_LOG - 1:0] hold_read_num, hold_write_num;

	// hold_write no necesita rst_n porque cualquier write inicial es inofensivo

	always_ff @(posedge clk) begin
		hold_write <= write;
		hold_read_num <= read_num;
		hold_write_num <= write_num;
		hold_write_data <= write_data;

		hold_read_data <= file[hold_read_num];
		if (hold_write)
			file[hold_write_num] <= hold_write_data;

		read_data <= hold_read_data;
	end

endmodule

module gfx_shader_table
import gfx::*;
#(int DATA_WIDTH = 0,
  int READ_PORTS = 0)
(
	input  logic                   clk,

	input  group_id                write_group,
	                               read_groups[READ_PORTS],

	input  logic[DATA_WIDTH - 1:0] write,
	input  logic                   write_enable,

	output logic[DATA_WIDTH - 1:0] read[READ_PORTS]
);

	genvar i;

	generate
		for (i = 0; i < READ_PORTS; ++i) begin: ports
			logic write_enable_hold;
			group_id read_group_hold, write_group_hold;
			logic[DATA_WIDTH - 1:0] data[1 << $bits(group_id)], read_hold, write_hold;

			always_ff @(posedge clk) begin
				write_hold <= write;
				read_group_hold <= read_groups[i];
				write_group_hold <= write_group;
				write_enable_hold <= write_enable;

				read_hold <= data[read_group_hold];

				if (write_enable_hold)
					data[write_group_hold] <= write_hold;

				read[i] <= read_hold;
			end
		end
	endgenerate

endmodule
