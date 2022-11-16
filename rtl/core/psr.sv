`include "core/uarch.sv"

module core_psr
(
	input  logic       clk,
	                   rst_n,
	                   write,
	                   saved,
	                   wr_flags,
	                   wr_control,
	                   update_flags,
	                   alu_v_valid,
	input  psr_flags   alu_flags,
	input  word        psr_wr,

	output psr_flags   flags,
	output psr_intmask mask,
	output psr_mode    mode,
	output word        cpsr_rd,
	                   spsr_rd
);

	typedef struct packed
	{
		psr_flags   flags;
		psr_intmask mask;
		psr_mode    mode;
	} psr_state;

	typedef struct packed
	{
		psr_flags   nzcv;
		logic       q;
		logic[1:0]  reserved0;
		logic       j;
		logic[3:0]  reserved1,
				    ge;
		logic[5:0]  reserved2;
		logic       e;
		logic       a;
		psr_intmask if_;
		logic       t;
		psr_mode    m;
	} psr_word;

	psr_word cpsr_word /*verilator public*/, spsr_word, wr_word;
	psr_flags next_flags;
	psr_state cpsr, spsr, spsr_svc, spsr_abt, spsr_und, spsr_irq, spsr_fiq,
	          wr_state, wr_clean;

	assign mode = cpsr.mode;
	assign mask = cpsr.mask;
	assign flags = cpsr.flags;
	assign wr_word = psr_wr;
	assign cpsr_rd = cpsr_word;
	assign spsr_rd = spsr_word;
	assign {wr_state.flags, wr_state.mask, wr_state.mode} = {wr_word.nzcv, wr_word.if_, wr_word.m};

`ifdef VERILATOR
	psr_word spsr_svc_word /*verilator public*/,
	         spsr_abt_word /*verilator public*/,
	         spsr_und_word /*verilator public*/,
	         spsr_fiq_word /*verilator public*/,
	         spsr_irq_word /*verilator public*/;

	always_comb begin
		spsr_svc_word = {$bits(spsr_svc_word){1'b0}};
		spsr_abt_word = {$bits(spsr_abt_word){1'b0}};
		spsr_und_word = {$bits(spsr_und_word){1'b0}};
		spsr_irq_word = {$bits(spsr_irq_word){1'b0}};
		spsr_fiq_word = {$bits(spsr_fiq_word){1'b0}};

		spsr_svc_word.a = 1;
		spsr_abt_word.a = 1;
		spsr_und_word.a = 1;
		spsr_irq_word.a = 1;
		spsr_fiq_word.a = 1;

		{spsr_svc_word.nzcv, spsr_svc_word.if_, spsr_svc_word.m}
			= {spsr_svc.flags, spsr_svc.mask, spsr_svc.mode};

		{spsr_abt_word.nzcv, spsr_abt_word.if_, spsr_abt_word.m}
			= {spsr_abt.flags, spsr_abt.mask, spsr_abt.mode};

		{spsr_und_word.nzcv, spsr_und_word.if_, spsr_und_word.m}
			= {spsr_und.flags, spsr_und.mask, spsr_und.mode};

		{spsr_irq_word.nzcv, spsr_irq_word.if_, spsr_irq_word.m}
			= {spsr_irq.flags, spsr_irq.mask, spsr_irq.mode};

		{spsr_fiq_word.nzcv, spsr_fiq_word.if_, spsr_fiq_word.m}
			= {spsr_fiq.flags, spsr_fiq.mask, spsr_fiq.mode};
	end
`endif

	always_comb begin
		next_flags = alu_flags;
		if(!alu_v_valid)
			next_flags.v = flags.v;

		unique case(mode)
			`MODE_SVC: spsr = spsr_svc;
			`MODE_ABT: spsr = spsr_abt;
			`MODE_UND: spsr = spsr_und;
			`MODE_IRQ: spsr = spsr_irq;
			`MODE_FIQ: spsr = spsr_fiq;
			default:   spsr = cpsr;
		endcase

		cpsr_word = {$bits(cpsr_word){1'b0}};
		spsr_word = {$bits(spsr_word){1'b0}};
		{cpsr_word.a, spsr_word.a} = 2'b11;

		{cpsr_word.nzcv, cpsr_word.if_, cpsr_word.m} = {flags, mask, mode};
		{spsr_word.nzcv, spsr_word.if_, spsr_word.m} = {spsr.flags, spsr.mask, spsr.mode};

		wr_clean = wr_state;
		unique case(wr_state.mode)
			`MODE_USR, `MODE_FIQ, `MODE_IRQ, `MODE_SVC,
			`MODE_ABT, `MODE_UND, `MODE_SYS: ;

			default:
				wr_clean.mode = mode;
		endcase

		if(!wr_flags)
			wr_clean.flags = flags;

		if(!wr_control) begin
			wr_clean.mask = mask;
			wr_clean.mode = mode;
		end

		if(mode == `MODE_USR) begin
			wr_clean.mask = mask;
			wr_clean.mode = `MODE_USR;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			cpsr.mode <= `MODE_SVC;
			cpsr.flags <= 4'b0000;
			cpsr.mask.i <= 1;
			cpsr.mask.f <= 1;

			spsr_svc <= {$bits(spsr_svc){1'b0}};
			spsr_abt <= {$bits(spsr_svc){1'b0}};
			spsr_und <= {$bits(spsr_svc){1'b0}};
			spsr_irq <= {$bits(spsr_svc){1'b0}};
			spsr_fiq <= {$bits(spsr_svc){1'b0}};
		end else begin
			if(!write) begin
				if(update_flags)
					cpsr.flags <= next_flags;
			end else if(!saved)
				cpsr <= wr_clean;
			else
				unique case(mode)
					`MODE_SVC: spsr_svc <= wr_clean;
					`MODE_ABT: spsr_abt <= wr_clean;
					`MODE_UND: spsr_und <= wr_clean;
					`MODE_IRQ: spsr_irq <= wr_clean;
					`MODE_FIQ: spsr_fiq <= wr_clean;
					default: ;
				endcase
		end

endmodule
