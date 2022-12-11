`include "core/mmu/format.sv"
`include "core/uarch.sv"

module core_mmu_pagewalk
(
	input  logic          clk,
	                      rst_n,

	input  logic          mmu_enable,
	input  mmu_base       mmu_ttbr,
	input  word           mmu_dac,

	input  logic          bus_ready,
	input  word           bus_data_rd,

	input  ptr            core_addr,
	input  word           core_data_wr,
	input  logic[3:0]     core_data_be,
	input  logic          core_start,
	                      core_write,

	output ptr            bus_addr,
	output word           bus_data_wr,
	output logic[3:0]     bus_data_be,
	output logic          bus_start,
	                      bus_write,

	output word           core_data_rd,
	output logic          core_ready,
	                      core_fault,
	                      core_fault_page,
	output ptr            core_fault_addr,
	output mmu_fault_type core_fault_type,
	output mmu_domain     core_fault_domain
);

	enum int unsigned
	{
		IDLE,
		L1,
		L2,
		DATA,
		FAULT
	} state;

	logic access_fault, valid_entry, skip_perms;
	logic[1:0] ap, entry_type;
	mmu_domain domain, entry_domain;
	mmu_fault_type access_fault_type;

	assign entry_type = bus_data_rd[1:0];
	assign core_fault_domain = domain;

	core_mmu_fault access_check
	(
		.fault(access_fault),
		.domain(entry_domain),
		.fault_type(access_fault_type),
		.*
	);

	mmu_l1_entry l1;
	assign l1 = bus_data_rd;

	mmu_l1_pagetable pagetable;
	assign pagetable = bus_data_rd;

	mmu_l1_section section;
	assign section = bus_data_rd;

	mmu_l2_large ptentry_large;
	assign ptentry_large = bus_data_rd;

	mmu_l2_small ptentry_small;
	assign ptentry_small = bus_data_rd;

	mmu_l2_smallext ptentry_smallext;
	assign ptentry_smallext = bus_data_rd;

	ptr target;
	word hold_data;
	logic hold_write;
	logic[3:0] hold_be;

	always_comb begin
		ap = 2'bxx;
		skip_perms = 0;
		valid_entry = 1;
		entry_domain = domain;

		unique case(state)
			L1:
				unique case(entry_type)
					`MMU_L1_PAGETABLE: begin
						ap = 2'bxx;
						skip_perms = 1;
					end

					`MMU_L1_SECTION: begin
						ap = section.ap;
						entry_domain = l1.domain;
					end

					// Tiny (1KiB wtf?) pages and supersections not supported
					default:
						valid_entry = 0;
				endcase

			L2:
				unique case(entry_type)
					`MMU_L2_FAULT:
						valid_entry = 0;

					`MMU_L2_LARGE:
						//TODO: ap3-ap2 (también en L2_SMALL)
						ap = ptentry_large.ap0;

					`MMU_L2_SMALL:
						ap = ptentry_small.ap0;

					`MMU_L2_SMALLEXT:
						ap = ptentry_smallext.ap;
				endcase

			default:
				valid_entry = 1'bx;
		endcase
	end

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			state <= IDLE;
			target <= 0;
			domain <= 0;

			hold_be <= 0;
			hold_data <= 0;
			hold_write <= 0;

			bus_addr <= 0;
			bus_start <= 0;
			bus_write <= 0;
			bus_data_be <= 0;
			bus_data_wr <= 0;

			core_ready <= 0;
			core_fault <= 0;
			core_data_rd <= 0;
			core_fault_page <= 0;
			core_fault_addr <= 0;
			core_fault_type <= 0;
		end else begin
			if(bus_start)
				bus_start <= 0;

			if(core_ready)
				core_ready <= 0;

			if(core_fault)
				core_fault <= 0;

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
					if(bus_ready) begin
						domain <= l1.domain;

						unique case(entry_type)
							`MMU_L1_PAGETABLE: begin
								state <= L2;
								bus_addr <= {pagetable.base, target `MMU_L2_INDEX};
							end

							`MMU_L1_SECTION: begin
								state <= DATA;
								bus_addr <= {section.base, target `MMU_SECTION_INDEX};
								bus_write <= hold_write;
								bus_data_wr <= hold_data;
								bus_data_be <= hold_be;
							end

							default: ;
						endcase
					end

				L2:
					if(bus_ready) begin
						state <= DATA;

						bus_write <= hold_write;
						bus_data_wr <= hold_data;
						bus_data_be <= hold_be;

						unique case(entry_type)
							`MMU_L2_FAULT: ;

							`MMU_L2_LARGE:
								bus_addr <= {ptentry_large.base, target `MMU_LARGE_INDEX};

							`MMU_L2_SMALL, `MMU_L2_SMALLEXT:
								bus_addr <= {ptentry_small.base, target `MMU_SMALL_INDEX};
						endcase
					end

				DATA:
					if(bus_ready) begin
						state <= IDLE;
						bus_write <= 0;
						core_ready <= 1;
						core_data_rd <= bus_data_rd;
					end

				FAULT: begin
					state <= IDLE;
					core_fault <= 1;
					core_ready <= 1;
					core_fault_addr <= target;
				end
			endcase

			if((state == L1 || state == L2) && bus_ready) begin
				if(access_fault) begin
					state <= FAULT;
					core_fault_type <= access_fault_type;
					core_fault_page <= state == L2;
				end else
					bus_start <= 1;
			end
		end

endmodule
