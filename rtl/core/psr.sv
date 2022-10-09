`include "core/uarch.sv"

module core_psr
(
	input  logic     clk,
	                 update_flags,
	                 alu_v_valid,
	input  psr_flags alu_flags,

	output psr_flags flags
);

	/* Este diseño de doble búfer es importante por rendimiento. Reducirlo
	 * a uno más "sencillo" tiene un costo de casi 40MHz menos en Fmax.
	 * Esto se debe a que el CPSR es el mayor mercado del core, se encuentra
	 * conectado a cycles, regs, alu y decode. La dependencia con decode en
	 * particular es crítica debido a que el condition code se especifica en
	 * términos de banderas de CPSR. Una ruta combinacional que atraviese flags
	 * iniciaría en cycles, tomaría valores de regs, llegaría a ALU, caería
	 * en flags y, debido al operand forwarding que se necesita por hazards de
	 * pipeline, esa misma señal seguiría combinacionalmente hacia decode para
	 * finalmente registrar en cycles nuevamente. Tal cosa es impermisible.
	 */

	psr_flags cpsr_flags, next_flags, wr_flags;
	logic pending_update;

	assign flags = pending_update ? wr_flags : cpsr_flags;

	always_comb begin
		next_flags = flags;

		if(update_flags) begin
			next_flags = alu_flags;
			if(~alu_v_valid)
				next_flags.v = flags.v;
		end
	end

	always_ff @(posedge clk) begin
		wr_flags <= next_flags;
		if(pending_update)
			cpsr_flags <= flags;

		pending_update <= update_flags;
	end

	initial begin
		flags = 4'b0000;
		cpsr_flags = 4'b0000;
		pending_update = 0;
	end

endmodule
