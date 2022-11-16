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
	output word        psr_rd
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

	/* Este diseño de doble búfer es importante por rendimiento. Reducirlo
	 * a uno más "sencillo" tiene una pérdida de casi 40MHz en Fmax.
	 * Esto se debe a que el CPSR es el mayor mercado del core, se encuentra
	 * conectado a cycles, regs, alu y decode. La dependencia con decode en
	 * particular es crítica debido a que el condition code se especifica en
	 * términos de banderas de CPSR. Una ruta combinacional que atraviese flags
	 * iniciaría en cycles, tomaría valores de regs, llegaría a ALU, caería
	 * en flags y, debido al operand forwarding que se necesita por hazards de
	 * pipeline, esa misma señal seguiría combinacionalmente hacia decode para
	 * finalmente registrar en cycles nuevamente. Tal cosa es impermisible.
	 */

	logic pending_update;
	psr_word rd_word, wr_word;
	psr_flags next_flags, wr_alu_flags;
	psr_state cpsr, spsr, spsr_svc, spsr_abt, spsr_und, spsr_irq, spsr_fiq,
	          wr_state, wr_clean;

	assign mode = cpsr.mode;
	assign mask = cpsr.mask;
	assign flags = pending_update ? wr_alu_flags : cpsr.flags;
	assign psr_rd = rd_word;
	assign wr_word = psr_wr;
	assign {wr_state.flags, wr_state.mask, wr_state.mode} = {wr_word.nzcv, wr_word.if_, wr_word.m};

`ifdef VERILATOR
	psr_word cpsr_word /*verilator public*/,
	         spsr_svc_word /*verilator public*/,
	         spsr_abt_word /*verilator public*/,
	         spsr_und_word /*verilator public*/,
	         spsr_fiq_word /*verilator public*/,
	         spsr_irq_word /*verilator public*/;

	assign {cpsr_word.nzcv, cpsr_word.if_, cpsr_word.m} = {cpsr.flags, cpsr.mask, cpsr.mode};

	assign {spsr_svc_word.nzcv, spsr_svc_word.if_, spsr_svc_word.m}
		= {spsr_svc.flags, spsr_svc.mask, spsr_svc.mode};

	assign {spsr_abt_word.nzcv, spsr_abt_word.if_, spsr_abt_word.m}
		= {spsr_abt.flags, spsr_abt.mask, spsr_abt.mode};

	assign {spsr_und_word.nzcv, spsr_und_word.if_, spsr_und_word.m}
		= {spsr_und.flags, spsr_und.mask, spsr_und.mode};

	assign {spsr_irq_word.nzcv, spsr_irq_word.if_, spsr_irq_word.m}
		= {spsr_irq.flags, spsr_irq.mask, spsr_irq.mode};

	assign {spsr_fiq_word.nzcv, spsr_fiq_word.if_, spsr_fiq_word.m}
		= {spsr_fiq.flags, spsr_fiq.mask, spsr_fiq.mode};
`endif

	always_comb begin
		next_flags = flags;

		if(update_flags) begin
			next_flags = alu_flags;
			if(~alu_v_valid)
				next_flags.v = flags.v;
		end

		rd_word = {$bits(rd_word){1'b0}};
		rd_word.a = 1;

		if(saved)
			{rd_word.nzcv, rd_word.if_, rd_word.m} = {spsr.flags, spsr.mask, spsr.mode};
		else
			{rd_word.nzcv, rd_word.if_, rd_word.m} = {flags, mask, mode};

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
			wr_alu_flags <= 4'b0000;
			pending_update <= 0;

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
			wr_alu_flags <= next_flags;
			pending_update <= !write && update_flags;

			if(!write) begin
				if(pending_update)
					cpsr.flags <= wr_alu_flags;
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
