module core_mmu_arbiter
(
	input  logic      clk,
	                  rst_n,

	input  logic      bus_ready,
	                  bus_ex_fail,
	input  word       bus_data_rd,
	                  data_data_wr,
	input  ptr        insn_addr,
	                  data_addr,
	input  logic      insn_start,
	                  data_start,
	                  data_write,
	                  data_ex_lock,
	input  logic[3:0] data_data_be,

	output word       bus_data_wr,
	output logic[3:0] bus_data_be,
	output ptr        bus_addr,
	output logic      bus_start,
	                  bus_write,
	                  bus_ex_lock,
	                  insn_ready,
	                  data_ready,
	                  data_ex_fail,
	output word       insn_data_rd,
	                  data_data_rd
);

	enum int unsigned
	{
		INSN,
		DATA
	} master, next_master;

	ptr hold_addr;
	word hold_data_wr;
	logic active, hold_ex_lock, hold_start, hold_write, hold_issue, hold_free, transition;
	logic[3:0] hold_data_be;

	assign data_ex_fail = bus_ex_fail;
	assign insn_data_rd = bus_data_rd;
	assign data_data_rd = bus_data_rd;

	always_comb begin
		next_master = master;
		if(bus_ready || !active)
			unique case(master)
				DATA: next_master = data_start ? DATA : INSN;
				INSN: next_master = !data_start && !hold_start ? INSN : DATA;
			endcase

		// Causa UNOPTFLAT en Verilator con assign
		transition = master != next_master;
		hold_issue = transition && hold_start;
		hold_free = transition || !hold_start;

		insn_ready = 0;
		data_ready = 0;

		unique case(master)
			INSN: insn_ready = bus_ready;
			DATA: data_ready = bus_ready;
		endcase

		bus_data_wr = data_data_wr;
		unique case(next_master)
			INSN: begin
				bus_addr = insn_addr;
				bus_write = 0;
				bus_start = insn_start;
				bus_data_be = 4'b1111;
				bus_ex_lock = 0;
			end

			DATA: begin
				bus_addr = data_addr;
				bus_write = data_write;
				bus_start = data_start;
				bus_data_be = data_data_be;
				bus_ex_lock = data_ex_lock;
			end
		endcase

		if(hold_issue) begin
			bus_addr = hold_addr;
			bus_write = hold_write;
			bus_start = 1;
			bus_data_wr = hold_data_wr;
			bus_data_be = hold_data_be;
			bus_ex_lock = hold_ex_lock;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			master <= INSN;
			active <= 0;

			hold_addr <= 30'b0;
			hold_start <= 0;
			hold_write <= 0;
			hold_data_wr <= 0;
			hold_data_be <= 0;
			hold_ex_lock <= 0;
		end else begin
			master <= next_master;
			active <= bus_start || (active && !bus_ready);

			if(hold_free)
				unique case(next_master)
					INSN: begin
						hold_addr <= data_addr;
						hold_start <= data_start;
						hold_write <= data_write;
						hold_data_wr <= data_data_wr;
						hold_data_be <= data_data_be;
						hold_ex_lock <= data_ex_lock;
					end

					DATA: begin
						hold_addr <= insn_addr;
						hold_start <= insn_start;
						hold_write <= 0;
						hold_data_be <= 4'b1111;
						hold_ex_lock <= 0;
					end
				endcase
		end

endmodule
