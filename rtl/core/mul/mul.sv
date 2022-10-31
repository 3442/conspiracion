module core_mul
#(parameter U=32)
(   // realiza la operación a * b + c = q
	input logic[U - 1:0]	a,		// primer sumando
							b,		// segundo sumando
	input logic[U - 1:0]	c_hi,	// parte más significativa de c
							c_lo,	// parte menos significativa de c
	input logic				c_size,	// 1 si c es de 2 words, cualquier otro valor si c es de 1 word
							clk,	// clock, ya que es una máquina de estados
							rst,	// reset
							add,	// 1 si c se suma
							sig,	// 1 si a y b son signed
							q_size,	// 1 si q es de 2 words, cualquier otro valor si es de 1 word
							start,	// 1 indica que se inicie la multiplicacion

	output  logic [U - 1:0] q_hi,	// parte más significativa del resultado
	output  logic [U - 1:0] q_lo,	// parte menos significativa del resultado
	output  logic [2*U-1:0] result,
	output  logic 			n,		// no hay C ni V, ya que se dejan unaffected
							z,
							q_sig,	// 1 si q es signed, cualquier otro valor si es unsigned
							rdy		// 1 cuando la multiplicación está lista
	
	//*Se asume lo siguiente:
	//	- Las señales de entrada son constantes desde el instante en el que start es 1 hasta que rdy sea 1
	//	- El valor de start puede cambiar durante la multiplicación, pero va a ser ignorado hasta que rdy sea 1
	//	- El valor de q es UNPREDICTABLE hasta que rdy sea 1
	//	- Las condiciones para iniciar una multiplicación son que rdy sea 1 y start sea 1
	//	- rdy solo no es 1 mientras la multiplicación se está realiresultando
);

	localparam W = U+1; //U=32 , W=33
	localparam IDLE = 1'b0;
	localparam START = 1'b1;

	logic signed [2*W - 1:0] result_ext, next_result, result_temp; //66
	logic next_state, current_state;
	logic [1:0] temp, next_temp; 	//temp es la concatenación de {Q0,Qres}
	logic [$clog2(U) - 1:0] count, next_count;
	logic [2*W - 1:0] c;	//66
	logic [2*W - 1:0] a_ext, b_ext;
	logic next_rdy;
	
	assign a_ext = {{(W+1){sig && a[W-1]}}, a}; //65
	assign b_ext = {{(W+1){sig && b[W-1]}}, b};

	always_comb
		if (!add)
			c = {(2*W){1'b0}};
		else if (c_size)
			c = {2'b0, c_hi, c_lo};
		else
			c = {{(W+1){sig && c_lo[W-1]}}, c_lo};

	always @ (posedge clk or negedge rst) begin
		if(!rst) begin
			result_ext      <= {(2*W){1'b0}};
			rdy      		<= 1'b0;
			current_state 	<= 1'b0;
			temp       		<= 2'd0;
			count      		<= {$clog2(U){1'b0}};
		end	
		else begin
			result_ext      <= next_result;
			rdy      		<= next_rdy;
			current_state 	<= next_state;
			temp       	   	<= next_temp;
			count      		<= next_count;
		end
	end

	always @ (*) begin 
		unique case(current_state)
			IDLE: begin
				next_count = {$clog2(U){1'b0}};
				next_rdy = 1'b0;
				if(start) begin
					next_state  = START;
					next_temp   = {a_ext[0],1'b0};
					next_result = {{(W/2){1'b0}},a_ext};
				end
				else begin
					next_state  = current_state;
					next_temp   = 2'd0;
					next_result = result_ext + c;
				end
			end

			START: begin
				unique case(temp)
					2'b10:   result_temp = {result_ext[2*W-1: U]-b_ext, result_ext[U-1:0]};
					2'b01:   result_temp = {result_ext[2*W-1: U]+b_ext, result_ext[U-1:0]};
					default: result_temp = result_ext;
				endcase
				next_temp  	= {a_ext[count+1],a_ext[count]};
				next_count 	= count + 1'b1;
				next_result	= result_temp >>> 1;
				next_rdy 	= (&count) ? 1'b1 : 1'b0; 
				next_state 	= (&count) ? IDLE : current_state;
				result 		= result_ext[2*U-1:0];	
				q_hi 		= result_ext[2*U-1: U];
				q_lo 		= result_ext[U-1: 0];
				n 			= result_ext[2*W-1];
				z 			= (|result_ext) ? 1'b0 : 1'b1; 
			end
		endcase
	end


endmodule


/*

module mul_tb();

	logic clk,rst,start;
	logic[7:0]X,Y;
	logic[15:0]Z;
	logic valid;

	always #5 clk = ~clk;

	core_mul_mul #(.W(8)) inst (.clk(clk),.rst(rst),.start(start),.a(X),.b(Y),.rdy(valid),.result(Z));

	initial
	$monitor($time,"a=%d, b=%d, ready=%d, Z=%d ",X,Y,valid,Z);
	initial
	begin
	X=255;Y=150;clk=1'b1;rst=1'b0;start=1'b0;
	#10 rst = 1'b1;
	#10 start = 1'b1;
	#10 start = 1'b0;
	@valid
	#10 X=-80;Y=-10;start = 1'b1;
	#10 start = 1'b0;
	end      
endmodule


*/
