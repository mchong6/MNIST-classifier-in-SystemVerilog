module testbench();

timeunit 1ns;

timeprecision 1ns; 

logic clk, reset;

always begin : CLOCK_GENERATION 
	#1 clk = ~clk;

end 

train_test train_mod(.clk, .reset);

	
initial begin : CLOCK_INITALIZATION 
	clk = 0; 
end 

initial begin : TEST_VECTORS

reset = 1; 
#2 reset = 0; 

end
endmodule 
