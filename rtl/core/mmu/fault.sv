`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_mmu_fault
(
	input  logic          valid_entry,
	                      skip_perms,
	input  word           mmu_dac,
	input  mmu_domain     domain,
	input  logic[1:0]     ap,
	input  logic          privileged,
	                      write,

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
				/* Hay una diferencia importante entre lo que dicen los
				 * manuales y lo que al parecer pasa realmente. Según
				 * el source del kernel, 0b00 debe permitir lecturas
				 * desde modos privilegiados (PTE_SMALL_AP_UNO_SRO),
				 * lo cual corresponde al caso con S = 1 en la tabla B4-1
				 * del ARM ARM. Por otro lado, el kernel nunca usa su propia
				 * definición de CR_S. Mi única explicación para que esto
				 * funcione es que los cores legacy tienen S = 1 en reset
				 * y a nadie nunca se le ocurrió revisar eso, o tal vez
				 * el manual está mal.
				 *
				 * Todo esto resulta en que, si se interpretan los bits AP
				 * como dice el manual de ARMv6, la página inmediatamente
				 * posterior a tabla de vectores altos del kernel provoque
				 * un prefetch abort (!!!) cuando los vectores saltan a esta,
				 * lo cual causa un bucle infinito de aborts a la primera IRQ.
				 */
				unique case(ap)
					2'b00:
						fault = !privileged || write;

					2'b01:
						fault = !privileged;

					2'b10:
						fault = !privileged && write;

					2'b11: ;
				endcase
		end
	end

endmodule
