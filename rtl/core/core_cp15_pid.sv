`include "core/cp15_map.sv"
`include "core/uarch.sv"

module core_cp15_pid
(
	input  logic     clk,
	                 rst_n,

	input  logic     load,
	                 transfer,
	input  word      write,
	input  cp_opcode op2,

	output word      read
);

	word fsce_id, context_id, tpidrurw, tpidruro, tpidrprw;

	always_comb
		unique case (op2)
			`CP15_PID_FSCE:     read = fsce_id;
			`CP15_PID_CONTEXT:  read = context_id;
			`CP15_PID_TPIDRURW: read = tpidrurw;
			`CP15_PID_TDIDRURO: read = tpidruro;
			`CP15_PID_TDIDRPRW: read = tpidrprw;
			default:            read = {$bits(read){1'bx}};
		endcase

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			fsce_id <= 0;
			context_id <= 0;
			tpidrurw <= 0;
			tpidruro <= 0;
			tpidrprw <= 0;
		end else if (transfer && !load)
			unique case (op2)
				`CP15_PID_FSCE:     fsce_id <= write;
				`CP15_PID_CONTEXT:  context_id <= write;
				`CP15_PID_TPIDRURW: tpidrurw <= write;
				`CP15_PID_TDIDRURO: tpidruro <= write;
				`CP15_PID_TDIDRPRW: tpidrprw <= write;
				default: ;
			endcase

endmodule
