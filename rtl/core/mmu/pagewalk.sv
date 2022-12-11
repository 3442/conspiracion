`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_mmu_pagewalk
(
	input  logic      clk,
	                  rst_n,

	input  logic      mmu_enable,
	input  mmu_base   mmu_ttbr,

	input  logic      bus_ready,
	input  word       bus_data_rd,

	input  ptr        core_addr,
	input  word       core_data_wr,
	input  logic[3:0] core_data_be,
	input  logic      core_start,
	                  core_write,

	output ptr        bus_addr,
	output word       bus_data_wr,
	output logic[3:0] bus_data_be,
	output logic      bus_start,
	                  bus_write,

	output logic      core_ready,
	output word       core_data_rd
);

	enum int unsigned
	{
		IDLE,
		L1,
		L2,
		DATA,
		FAULT
	} state;

	mmu_l1_pagetable pagetable;
	assign pagetable = bus_data_rd;

	mmu_l1_section section;
	assign section = bus_data_rd;

	mmu_l2_large ptentry_large;
	assign ptentry_large = bus_data_rd;

	mmu_l2_small ptentry_small;
	assign ptentry_small = bus_data_rd;

	ptr target;
	word hold_data;
	logic[3:0] hold_be;

	logic hold_write;

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			state <= IDLE;
			target <= 0;

			hold_be <= 0;
			hold_data <= 0;
			hold_write <= 0;

			bus_addr <= 0;
			bus_start <= 0;
			bus_write <= 0;
			bus_data_be <= 0;
			bus_data_wr <= 0;

			core_ready <= 0;
			core_data_rd <= 0;
		end else begin
			if(bus_start)
				bus_start <= 0;

			if(core_ready)
				core_ready <= 0;

			unique case(state)
				IDLE:
					if(core_start) begin
						bus_start <= 1;

						if(mmu_enable) begin
							target <= core_addr;
							hold_be <= core_data_be;
							hold_data <= core_data_wr;
							hold_write <= core_write;

							state <= L1;
							bus_addr <= {mmu_ttbr, core_addr `MMU_L1_INDEX};
						end else begin
							state <= DATA;
							bus_addr <= core_addr;
							bus_write <= core_write;
							bus_data_wr <= core_data_wr;
							bus_data_be <= core_data_be;
						end
					end

				L1:
					if(bus_ready)
						unique case(bus_data_rd[1:0])
							`MMU_L1_PAGETABLE: begin
								state <= L2;
								bus_addr <= {pagetable.base, target `MMU_L2_INDEX};
								bus_start <= 1;
							end

							`MMU_L1_SECTION: begin
								state <= DATA;

								bus_addr <= {section.base, target `MMU_SECTION_INDEX};
								bus_start <= 1;
								bus_write <= hold_write;
								bus_data_wr <= hold_data;
								bus_data_be <= hold_be;
							end

							// Tiny (1KiB wtf?) pages and supersections not supported
							default:
								state <= FAULT;
						endcase

				L2:
					if(bus_ready) begin
						state <= DATA;

						bus_write <= hold_write;
						bus_data_wr <= hold_data;
						bus_data_be <= hold_be;

						unique case(bus_data_rd[1:0])
							`MMU_L2_FAULT:
								state <= FAULT;

							`MMU_L2_LARGE: begin
								bus_addr <= {ptentry_large.base, target `MMU_LARGE_INDEX};
								bus_start <= 1;
							end

							`MMU_L2_SMALL, `MMU_L2_SMALLEXT: begin
								bus_addr <= {ptentry_small.base, target `MMU_SMALL_INDEX};
								bus_start <= 1;
							end
						endcase
					end

				DATA:
					if(bus_ready) begin
						state <= IDLE;
						bus_write <= 0;
						core_ready <= 1;
						core_data_rd <= bus_data_rd;
					end

				//TODO
				FAULT: ;
			endcase
		end

endmodule
