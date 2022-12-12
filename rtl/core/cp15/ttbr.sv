`include "core/cp15/map.sv"
`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_cp15_ttbr
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,

	output word      read /*verilator public*/,
	output mmu_base  mmu_ttbr
);

	logic s, c;
	cp15_ttbr read_ttbr, write_ttbr;
	logic[1:0] rgn;

	assign read = read_ttbr;
	assign write_ttbr = write;

	assign read_ttbr.s = s;
	assign read_ttbr.c = c;
	assign read_ttbr.sbz = 9'd0;
	assign read_ttbr.rgn = rgn;
	assign read_ttbr.imp = 0;
	assign read_ttbr.base = mmu_ttbr;

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			s <= 0;
			c <= 0;
			rgn <= 0;
			mmu_ttbr <= 0;
		end else if(transfer && !load) begin
			s <= write_ttbr.s;
			c <= write_ttbr.c;
			rgn <= write_ttbr.rgn;
			mmu_ttbr <= write_ttbr.base;
		end

endmodule
