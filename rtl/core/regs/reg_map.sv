`include "core/uarch.sv"

module core_reg_map
(
	input  reg_num   r,
	input  psr_mode  mode,
	output logic     is_pc,
	output reg_index index
);

	reg_index usr;
	assign usr = {1'b0, r};

	always_comb begin
		index = 5'bxxxxx;
		is_pc = r == `R15;

		if(~is_pc)
			unique case(mode)
				`MODE_USR, `MODE_SYS: index = usr;
				`MODE_FIQ: index = r >=  8 ? usr +  7 : usr;
				`MODE_IRQ: index = r >= 13 ? usr +  9 : usr;
				`MODE_UND: index = r >= 13 ? usr + 11 : usr;
				`MODE_ABT: index = r >= 13 ? usr + 13 : usr;
				`MODE_SVC: index = r >= 13 ? usr + 15 : usr;
				default: ;
			endcase
	end

endmodule
