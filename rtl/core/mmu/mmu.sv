module core_mmu
(
	input  logic clk,

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

	enum
	{
		INSN,
		DATA
	} master, next_master;

	logic active, hold_start, hold_write, hold_issue, hold_free, transition;
	ptr hold_addr;
	word hold_data_wr;

	//TODO
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

		unique case(next_master)
			INSN: begin
				bus_addr = insn_addr;
				bus_write = 0;
				bus_start = insn_start;
				bus_data_wr = {32{1'bx}};
			end

			DATA: begin
				bus_addr = data_addr;
				bus_write = data_write;
				bus_start = data_start;
				bus_data_wr = data_data_wr;
			end
		endcase

		if(hold_issue) begin
			bus_addr = hold_addr;
			bus_write = hold_write;
			bus_start = 1;
			bus_data_wr = hold_data_wr;
		end
	end

	always_ff @(posedge clk) begin
		master <= next_master;
		active <= bus_start || (active && !bus_ready);

		if(hold_free)
			unique case(next_master)
				INSN: begin
					hold_start <= data_start;
					hold_addr <= data_addr;
					hold_write <= data_write;
					hold_data_wr <= data_data_wr;
				end

				DATA: begin
					hold_start <= insn_start;
					hold_addr <= insn_addr;
					hold_write <= 0;
				end
			endcase
	end

	initial begin
		master = INSN;
		active = 0;

		hold_addr = 30'b0;
		hold_start = 0;
		hold_write = 0;
		hold_data_wr = 0;
	end

endmodule
