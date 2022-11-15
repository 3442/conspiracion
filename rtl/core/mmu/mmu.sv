module core_mmu
(
	input  logic clk,
	             rst_n,

	input  logic bus_ready,
	input  word  bus_data_rd,
	             data_data_wr,
	input  ptr   insn_addr,
	             data_addr,
	input  logic insn_start,
	             data_start,
	             data_write,

	output word  bus_data_wr,
	output ptr   bus_addr,
	output logic bus_start,
	             bus_write,
	             insn_ready,
	             data_ready,
	output word  insn_data_rd,
	             data_data_rd
);

	//TODO
	core_mmu_arbiter arbiter
	(
		.*
	);

endmodule
