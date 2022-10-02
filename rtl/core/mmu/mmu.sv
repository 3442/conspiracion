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

	//TODO
	assign insn_data_rd = bus_data_rd;
	assign data_data_rd = bus_data_rd;

	always_comb begin
		next_master = master;
		if(bus_ready) begin
			if(insn_start)
				next_master = INSN;
			else if(data_start)
				next_master = DATA;
		end

		insn_ready = 0;
		data_ready = 0;

		unique case(master)
			INSN: insn_ready = bus_ready;
			DATA: data_ready = bus_ready;
		endcase

		unique case(next_master)
			INSN: begin
				bus_addr = insn_addr;
				bus_data_wr = {32{1'bx}};
			end

			DATA: begin
				bus_addr = data_addr;
				bus_data_wr = data_data_wr;
			end
		endcase
	end

	always @(posedge clk) begin
		master <= next_master;

		unique case(next_master)
			INSN: begin
				bus_start <= insn_start;
				bus_write <= 0;
			end

			DATA: begin
				bus_start <= data_start;
				bus_write <= data_write;
			end
		endcase
	end

	initial begin
		master = INSN;
		bus_start = 0;
		bus_write = 0;
	end

endmodule
