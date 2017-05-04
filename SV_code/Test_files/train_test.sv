/* Module used to test backpropagation */
module train_test(input logic clk, reset);

shortint cur_weights[9:0];
shortint new_weights[9:0];
logic W_en, start_stream, start_pixel;
logic [4:0] H_Cont_down, V_Cont_down;

	shortint output_test[9:0]; 
	assign output_test[0] = -1000; 
	assign output_test[1] = -207; 
	assign output_test[2] = -468;
	assign output_test[3] = -450; 
	assign output_test[4] = 1148; 
	assign output_test[5] = -2881; 
	assign output_test[6] = 821; 
	assign output_test[7] = 810;
	assign output_test[8] = -2295; 
	assign output_test[9] = -440; 
	
pix_sim unit1(.clk, .reset, .H_cont(H_Cont_down), .V_cont(V_Cont_down), .start_stream(start_stream), .start_pixel);
//Grab weights corresponding to current pixel
weights_controller weight(.clk,
                          .H_count(H_Cont_down), 
                          .V_count(V_Cont_down), 
                          .W_en, 
                          .weights_in(new_weights), 
                          .weights_out(cur_weights)); 
								  
train train_unit(.clk, 
					  .reset, 
					  .start_stream,
					  .train_label_b(4'b0), 
					  .start_train_sw(1'b1), 
					  .pixel(1'b1),
					  .weights_in(cur_weights),
					  .output_test,
					  .start_pixel,
					  .new_weights,
					  .W_en);
endmodule
