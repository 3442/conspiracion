`include "core/decode/isa.sv"
`include "core/uarch.sv"

module core_porch_conds
(
	input  word       insn,
	input  psr_flags  flags,

	output logic      execute,
	                  conditional,
	                  undefined
);

	always_comb begin
		undefined = 0;
		conditional = 1;

		unique case(insn `FIELD_COND)
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

			`COND_AL: begin
				execute = 1;
				conditional = 0;
			end

			`COND_UD: begin
				execute = 1'bx;
				conditional = 1'bx;
				undefined = 1;
			end
		endcase
	end

endmodule
