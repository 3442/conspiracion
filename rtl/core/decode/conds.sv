`include "core/isa.sv"
`include "core/uarch.sv"

module core_decode_conds
(
	input  logic[3:0] cond,
	input  psr_flags  flags,
	output logic      execute,
	                  undefined
);

	always_comb begin
		undefined = 0;

		unique case(cond)
			`COND_EQ: execute =  flags.z;
			`COND_NE: execute = ~flags.z;
			`COND_HS: execute =  flags.c;
			`COND_LO: execute = ~flags.c;
			`COND_MI: execute =  flags.n;
			`COND_PL: execute = ~flags.n;
			`COND_VS: execute =  flags.v;
			`COND_VC: execute = ~flags.v;
			`COND_HI: execute =  flags.c  & ~flags.z;
			`COND_LS: execute = ~flags.c  |  flags.z;
			`COND_GE: execute =  flags.n ~^  flags.v;
			`COND_LT: execute =  flags.n  ^  flags.v;
			`COND_GT: execute = ~flags.z  & (flags.n ~^ flags.v);
			`COND_LE: execute =  flags.z  | (flags.n  ^ flags.v);
			`COND_AL: execute = 1;

			`COND_UD: begin
				execute = 1'bx;
				undefined = 1;
			end
		endcase
	end

endmodule
