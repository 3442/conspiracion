module core_mul_mul
#(parameter W=32)
(
	input   logic[W - 1:0]      a,
                                b,
    input   logic               clk,

	output  logic[(W*2) - 1:0]  q,
	output  logic               z,
                                n
);

    logic[(W*2):0] booth;
    logic[1:0] Q; 
    logic[W-1:0] A, B;
    logic[W - 1:0] counter;

    initial begin
        booth = { W{1'b0}, b, 0 }
        Q = booth[1:0];
        A = booth[(W*2):W];
        B = a;
        counter = W;
    end

always@(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        booth = { W{1'b0}, b, 0 }
        Q = booth[1:0];
        //A = booth[(W*2):W];
        //B = a;
        counter = W;
    end 
    else begin

        A = booth[(W*2):W];

        unique case(Q)
            2'b01:
                booth[(W*2):W] = A + B;
                

            2'b10:
                booth[(W*2):W] = A - B;    
            
            // 2'b11 o 2'b00:
            default: ;
                
        endcase

        booth >>> 1;
        counter = counter - 1;
    end

    always_comb
        if(counter == 0) begin
            q = booth[(W*2):1]
        end
    end
endmodule
