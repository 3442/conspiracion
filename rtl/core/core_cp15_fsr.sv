`include "core/cp15_map.sv"
`include "core/mmu_format.sv"
`include "core/uarch.sv"

module core_cp15_fsr
(
	input  logic          clk,
	                      rst_n,

	input  logic          load,
	                      transfer,
	input  word           write,

	input  logic          fault_register,
	                      fault_page,
	input  mmu_fault_type fault_type,
	input  mmu_domain     fault_domain,

	output word           read /*verilator public*/
);

	logic fsr_page;
	mmu_domain fsr_domain;
	mmu_fault_type fsr_type;

	assign read = {24'd0, fsr_domain, fsr_type, fsr_page, 1'b1};

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			fsr_page <= 0;
			fsr_type <= 0;
			fsr_domain <= 0;
		end else if(fault_register) begin
			fsr_page <= fault_page;
			fsr_type <= fault_type;
			fsr_domain <= fault_domain;
		end else if(transfer && !load) begin
			fsr_page <= write[1];
			fsr_type <= write[3:2];
			fsr_domain <= write[7:4];
		end

endmodule
