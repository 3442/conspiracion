`include "core/uarch.sv"

module core_control_exception
(
	input  logic       clk,
	                   rst_n,

	input  ctrl_cycle  cycle,
	                   next_cycle,
	input  insn_decode dec,
	input  psr_intmask intmask,
	input  logic       issue,
	                   irq,
	                   high_vectors,
	                   undefined,
	                   prefetch_abort,
	                   mem_fault,

	output logic       escalating,
	                   exception,
	                   exception_offset_pc,
	output psr_mode    exception_mode,
	output word        exception_vector
);

	logic pending_irq, syscall;
	logic[2:0] vector_offset;

	//TODO: fiq

	assign exception = undefined || syscall || prefetch_abort || mem_fault || pending_irq;
	assign escalating = cycle.escalate;
	assign exception_vector = {{16{high_vectors}}, 11'b0, vector_offset, 2'b00};

	always @(posedge clk or negedge rst_n)
		if(!rst_n) begin
			syscall <= 0;
			pending_irq <= 0;
			vector_offset <= 0;
			exception_mode <= 0;
			exception_offset_pc <= 0;
		end else begin
			if(next_cycle.issue) begin
				syscall <= issue && dec.ctrl.swi;
				pending_irq <= issue && irq && !intmask.i;
			end

			// A2.6.10 Exception priorities
			if(mem_fault) begin
				vector_offset <= 3'b100;
				exception_mode <= `MODE_ABT;
			end else if(pending_irq) begin
				vector_offset <= 3'b110;
				exception_mode <= `MODE_IRQ;
			end else if(prefetch_abort) begin
				vector_offset <= 3'b011;
				exception_mode <= `MODE_ABT;
			end else if(undefined) begin
				vector_offset <= 3'b001;
				exception_mode <= `MODE_UND;
			end else if(syscall) begin
				vector_offset <= 3'b010;
				exception_mode <= `MODE_SVC;
			end

			if(next_cycle.escalate)
				exception_offset_pc <= !mem_fault;
		end

endmodule
