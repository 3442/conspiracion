`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_mmu_fault
(
	input  logic          valid_entry,
	                      skip_perms,
	input  word           mmu_dac,
	input  mmu_domain     domain,
	input  logic[1:0]     ap,

	output logic          fault, 
	output mmu_fault_type fault_type
);

	mmu_domain_ctrl domain_ctrl;

	always_comb begin
		unique case(domain)
			4'h0: domain_ctrl = mmu_dac[1:0];
			4'h1: domain_ctrl = mmu_dac[3:2];
			4'h2: domain_ctrl = mmu_dac[5:4];
			4'h3: domain_ctrl = mmu_dac[7:6];
			4'h4: domain_ctrl = mmu_dac[9:8];
			4'h5: domain_ctrl = mmu_dac[11:10];
			4'h6: domain_ctrl = mmu_dac[13:12];
			4'h7: domain_ctrl = mmu_dac[15:14];
			4'h8: domain_ctrl = mmu_dac[17:16];
			4'h9: domain_ctrl = mmu_dac[19:18];
			4'ha: domain_ctrl = mmu_dac[21:20];
			4'hb: domain_ctrl = mmu_dac[23:22];
			4'hc: domain_ctrl = mmu_dac[25:24];
			4'hd: domain_ctrl = mmu_dac[27:26];
			4'he: domain_ctrl = mmu_dac[29:28];
			4'hf: domain_ctrl = mmu_dac[31:30];
		endcase

		fault = 0;
		fault_type = `MMU_FAULT_ACCESS;

		if(!valid_entry) begin
			fault = 1;
			fault_type = `MMU_FAULT_WALK;
		end else if(!skip_perms) begin
			if(!domain_ctrl.allowed) begin
				fault = 1;
				fault_type = `MMU_FAULT_DOMAIN;
			end else if(!domain_ctrl.manager)
				unique case(ap)
					2'b00:
						fault = 1;

					//TODO: los demás solo se tienen efecto para unprivileged
					default: ;
				endcase
		end
	end

endmodule
