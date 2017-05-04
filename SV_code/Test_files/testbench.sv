module testbench();

timeunit 1ns;

timeprecision 1ns; 

logic clk, reset, load, pixel; 
always begin : CLOCK_GENERATION 
	#1 clk = ~clk;

end 

//logic [15:0] data_1, data_2;
//logic [31:0] out;
//assign data_1 = 16'd5;
//assign data_2 = 16'd2;

//mult_accum test(.aclr3(reset), .clock0(clk), .dataa(data_1), .datab(data_2), .result(out));
//multiply test(.clk(clk), .reset(reset), .load(start_stream), .pixel(pixel), .H_count(H_counter), .V_count(V_counter), .output_reg(output_reg)); 
new_top_level unit(.clk, .reset, .pixel(1'b1));

	
initial begin : CLOCK_INITALIZATION 
	clk = 0; 
end 

initial begin : TEST_VECTORS

reset = 1; 
#2 reset = 0; 


end
endmodule 
