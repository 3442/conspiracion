`include "core/uarch.sv"
`include "core/cp15_map.sv"

module core_cp15_syscfg
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  cp_opcode op2,
	input  word      write,

	output word      read,
	output logic     high_vectors,
	                 mmu_enable
);

	logic dcache_enable, icache_enable;

	cp15_syscfg_ctrl ctrl /*verilator public*/, write_ctrl;

	assign write_ctrl = write;

	always_comb begin
		ctrl = {$bits(ctrl){1'b0}};
		ctrl.m = mmu_enable;
		ctrl.c = dcache_enable;
		ctrl.l = 1;
		ctrl.d = 1;
		ctrl.p = 1;
		ctrl.z = 1;
		ctrl.i = icache_enable;
		ctrl.v = high_vectors;
		ctrl.dt = 1;
		ctrl.it = 1;

		unique case(op2)
			`CP15_SYSCFG_CTRL:
				read = ctrl;

			`CP15_SYSCFG_ACCESS:
				read = 0;

			default:
				read = 0;
		endcase
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			mmu_enable <= 0;
			high_vectors <= 0;
			dcache_enable <= 0;
			icache_enable <= 0;
		end else if(transfer && !load)
			unique case(op2)
				`CP15_SYSCFG_CTRL: begin
					mmu_enable <= write_ctrl.m;
					high_vectors <= write_ctrl.v;
					dcache_enable <= write_ctrl.c;
					icache_enable <= write_ctrl.i;
				end

				default: ;
			endcase

endmodule
