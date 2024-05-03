package gfx_isa;

	typedef logic[3:0] sgpr_num;
	typedef logic[2:0] vgpr_num;

	typedef union packed
	{
		sgpr_num sgpr;

		struct packed
		{
			logic[$bits(sgpr_num) - $bits(vgpr_num) - 1:0] reserved;
			vgpr_num                                       num;
		} vgpr;
	} xgpr_num;

	typedef struct packed
	{
		enum logic[1:0]
		{
			REGS_SVS = 2'b00,
			REGS_SSS = 2'b01,
			REGS_VVS = 2'b10,
			REGS_VVV = 2'b11
		} reg_mode;

		union packed
		{
			struct packed
			{
				logic b_is_imm;

				union packed
				{
					logic[12:0] imm;

					struct packed
					{
						logic      from_consts;
						logic[7:0] reserved;
						xgpr_num   r;
					} read;
				} b;

				xgpr_num ra,
				         rd;
			} rr;
		} dst_src;

		logic reg_rev;

		union packed
		{
			struct packed
			{
				enum logic[4:0]
				{
					INSN_FPINT_MOV  = 0,
					INSN_FPINT_FMUL = 1,
					INSN_FPINT_IMUL = 2,
					INSN_FPINT_FADD = 3,
					INSN_FPINT_RES4 = 4,
					INSN_FPINT_FMAX = 5,
					INSN_FPINT_RES6 = 6,
					INSN_FPINT_FMIN = 7,
					INSN_FPINT_RES8 = 8,
					INSN_FPINT_FCVT = 9,
					INSN_FPINT_RES[10:31]
				} op;
			} fpint;
		} by_class;

		enum logic[1:0]
		{
			INSN_FPINT = 0,
			INSN_MEM   = 1,
			INSN_SFU   = 2,
			INSN_GROUP = 3
		} insn_class;
	} insn_word;

endpackage
