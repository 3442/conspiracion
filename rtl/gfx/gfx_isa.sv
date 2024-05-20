package gfx_isa;

	typedef logic[3:0] sgpr_num;
	typedef logic[2:0] vgpr_num;

	typedef logic signed[7:0] pc_offset;

	typedef struct packed
	{
		sgpr_num sgpr;
	} xgpr_sgpr;

	typedef struct packed
	{
		logic[$bits(sgpr_num) - $bits(vgpr_num) - 1:0] reserved;
		vgpr_num                                       vgpr;
	} xgpr_vgpr;

	typedef xgpr_vgpr xgpr_num;

	typedef enum logic[1:0]
	{
		REGS_SVS = 2'b00,
		REGS_SSS = 2'b01,
		REGS_VVS = 2'b10,
		REGS_VVV = 2'b11
	} xgpr_mode;

	typedef struct packed
	{
		logic[12:0] imm;
	} dst_src_rr_b_imm;

	typedef struct packed
	{
		logic      from_consts;
		logic[7:0] reserved;
		xgpr_num   r;
	} dst_src_rr_b_read;

	typedef struct packed
	{
		logic             b_is_imm;
		dst_src_rr_b_read b;
		xgpr_num          ra,
		                  rd;
	} dst_src_rr;

	typedef enum logic[1:0]
	{
		INSN_FPINT = 2'd0,
		INSN_MEM   = 2'd1,
		INSN_SFU   = 2'd2,
		INSN_GROUP = 2'd3
	} insn_class;

	typedef enum logic[4:0]
	{
		INSN_FPINT_MOV  = 5'd0,
		INSN_FPINT_FMUL = 5'd1,
		INSN_FPINT_IMUL = 5'd2,
		INSN_FPINT_FADD = 5'd3,
		INSN_FPINT_RES4 = 5'd4,
		INSN_FPINT_FMAX = 5'd5,
		INSN_FPINT_RES6 = 5'd6,
		INSN_FPINT_FMIN = 5'd7,
		INSN_FPINT_RES8 = 5'd8,
		INSN_FPINT_FCVT = 5'd9,
		INSN_FPINT_RES[10:31]
	} insn_fpint_op;

	typedef struct packed
	{
		xgpr_mode     reg_mode;
		dst_src_rr    dst_src;
		logic         reg_rev;
		insn_fpint_op op;
		insn_class    op_class;
	} insn_fpint;

	typedef struct packed
	{
		xgpr_mode  reg_mode;
		dst_src_rr dst_src;
		logic      reg_rev;
		logic[3:0] reserved;
		logic      load;
		insn_class op_class;
	} insn_mem;

	typedef struct packed
	{
		xgpr_mode   reg_mode;
		dst_src_rr  dst_src;
		logic       reg_rev;
		logic[4:0]  op_data;
		insn_class  op_class;
	} insn_any;

endpackage
