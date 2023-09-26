module mp
(
    input  logic clk,
                 rst_n,
    
    // todas las señales de shutdown_request de otros procesadores
    input  logic [1:0] avl_address,
	input  logic       avl_read,
	                   avl_write,
	input  logic[31:0] avl_writedata,
    output logic[31:0] avl_readdata,

    input logic       cpu_halted_pe_0,
                      cpu_halted_pe_1,
                      cpu_halted_pe_2,
                      cpu_halted_pe_3,
	input logic       breakpoint_pe_0,
                      breakpoint_pe_1,
                      breakpoint_pe_2,
                      breakpoint_pe_3,    

    // señales de halt 
    output logic      halt_pe_0,
                      halt_pe_1,
                      halt_pe_2,
                      halt_pe_3,
                      step_pe_0,
                      step_pe_1,
                      step_pe_2,
                      step_pe_3
);

    logic[7:0] pe_status;
    logic halt, step, run;

    assign {step, run, halt} = avl_writedata[2:0];
    assign avl_readdata = {24'b0, pe_status};

    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            halt_pe_0 <= 0; //Encender solo el PE0
            halt_pe_1 <= 1;
            halt_pe_2 <= 1;
            halt_pe_3 <= 1;
            step_pe_1 <= 0;
            step_pe_2 <= 0;
            step_pe_3 <= 0;
            step_pe_4 <= 0;
            pe_status <= {($bits(pe_status)){1'b0}};
        end else begin

            pe_status <= { cpu_halted_pe_0,
        	               breakpoint_pe_0,
                           cpu_halted_pe_1,
                           breakpoint_pe_1,
                           cpu_halted_pe_2,
                           breakpoint_pe_2,
                           cpu_halted_pe_3,
                           breakpoint_pe_3 };

            unique case(avl_address)
                2'b00: begin
                    //Se hace halt hasta el siguiente ciclo después de que se 
                    //solicita el breakpoint
                    halt_pe_0 <= (halt_pe_0 || halt || breakpoint_pe_0) && !run && !step;
                    step_pe_0 <= !breakpoint_pe_0 || step;
                end
                2'b01: begin
                    halt_pe_1 <= ((halt_pe_1 || halt) && !run) || breakpoint_pe_1 || !step;
                    step_pe_1 <= !breakpoint_pe_1 || step;
                end
                2'b10: begin
                    halt_pe_2 <= ((halt_pe_2 || halt) && !run) || breakpoint_pe_2 || !step;
                    step_pe_2 <= !breakpoint_pe_2 || step;
                end
                2'b11: begin
                    halt_pe_3 <= ((halt_pe_3 || halt) && !run) || breakpoint_pe_3 || !step;
                    step_pe_3 <= !breakpoint_pe_3 || step;
                end      
            endcase
        end

endmodule