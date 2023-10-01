module smp_pe
#(parameter IS_BSP=0)
(
	input  logic	  clk,
	                  rst_n,
	
	input  logic      write,
	input  logic[7:0] writedata,
	output logic[7:0] readdata,

	input  logic      cpu_halted,
	                  breakpoint,

	output logic      halt,
	                  step
);

	struct packed
	{
		logic step, halt, run;
	} req;

	struct packed
	{
		logic breakpoint, cpu_halted;
	} status;

	assign req = writedata[$bits(req) - 1:0];
	assign readdata = {{(8 - $bits(status)){1'b0}}, status};

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			halt <= IS_BSP ? 0 : 1; // Boot es single-core
			step <= 0;
			status <= {($bits(status)){1'b0}};
		end else begin
			status.breakpoint <= breakpoint;
			status.cpu_halted <= cpu_halted;

			//Se hace halt hasta el siguiente ciclo después de que se 
			//solicita el breakpoint
			step <= (step && !breakpoint) || (req.step && write);
			halt <= (halt || breakpoint || (req.halt && write))
			     && !((req.run || req.step) && write);
		end

endmodule
