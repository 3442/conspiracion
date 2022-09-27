`include "core/uarch.sv"

module core_regs
(
	input  logic    clk,
	input  reg_num  rd_r_a,
	                rd_r_b,
	                wr_r,
	input  psr_mode rd_mode,
	                wr_mode,
	input  logic    wr_enable,
	input  word     wr_value,
	input  ptr      pc_visible,

	output word     rd_value_a,
	                rd_value_b,
	output logic    branch
);

	/* Las Cyclone V no tienen bloques de memoria con al menos dos puertos de
	 * lectura y uno de escritura (tres puertos), lo más que tienen son bloques
	 * de dos puertos en total. Podemos ponerle cinta a esto con dos copias
	 * sincronizadas del archivo de registros.
	 */

	logic rd_pc_a, rd_pc_b, wr_pc, file_wr_enable;
	reg_index rd_index_a, rd_index_b, wr_index;
	word pc_word, file_rd_value_a, file_rd_value_b;

	assign pc_word = {pc_visible, 2'b00};
	assign rd_value_a = rd_pc_a ? pc_word : file_rd_value_a;
	assign rd_value_b = rd_pc_b ? pc_word : file_rd_value_b;
	assign file_wr_enable = wr_enable & ~wr_pc;
	assign branch = wr_enable & wr_pc;

	core_reg_file a
	(
		.rd_index(rd_index_a),
		.rd_value(file_rd_value_a),
		.wr_enable(file_wr_enable),
		.*
	);

	core_reg_file b
	(
		.rd_index(rd_index_b),
		.rd_value(file_rd_value_b),
		.wr_enable(file_wr_enable),
		.*
	);

	core_reg_map map_rd_a
	(
		.r(rd_r_a),
		.mode(rd_mode),
		.is_pc(rd_pc_a),
		.index(rd_index_a)
	);

	core_reg_map map_rd_b
	(
		.r(rd_r_b),
		.mode(rd_mode),
		.is_pc(rd_pc_b),
		.index(rd_index_b)
	);

	core_reg_map map_wr
	(
		.r(wr_r),
		.mode(wr_mode),
		.is_pc(wr_pc),
		.index(wr_index)
	);

endmodule
