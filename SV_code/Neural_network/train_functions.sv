/* Backpropagates when SW17 is HIGH
 *
 * Inputs: start_stream - Indicate if its a pixel we want
 *         start_train_sw - SW[17], set to HIGH to train
 *         start_pixel - Indicate the start of an image 
 *         pixel - Input pixel
 *         output_test - Output for forward propagation
 *         weights_in - Current weights of pixel row
 *
 * Outputs: new_weights - new weights for each row of pixels (784)
 *          W_en - Write enable to save to OCM
 */
module train(input logic clk,
             input logic reset, 
             input logic start_stream,
             input logic [3:0] train_label_b, //SW[16:13]
             input logic start_train_sw,  //SW[17]
             input logic start_pixel,
             input logic pixel,
             input shortint weights_in[9:0],
             input shortint output_test[9:0],
             output shortint new_weights[9:0],
             output logic W_en);

	shortint train_label_dec[9:0], delta_error[9:0]; 

	SW_b_to_dec switch_unit(.train_label_b, 
                            .train_label_dec); 
													
	MSE_derivative computer_derivative(.train_label_dec,  
                                       .output_test, 
                                       .result(delta_error));
												  
	train_state_machine train_unit(.clk, 
                                   .reset, 
                                   .start_stream,
                                   .start_train_sw,  
                                   //.start_train, 
                                   .start_pixel,
                                   .result_prev(delta_error), 
                                   .pixel, 
                                   .weights(weights_in), 
                                   .new_weights,
                                   .W_en); 
endmodule


/* Convert binary number to one-hot vector 
 *
 * Inputs: train_label_b - Binary label
 *
 * Outputs: train_label_dec - One-hot label
 */
module SW_b_to_dec(input [3:0] train_label_b, //input from the 10 switches (won't use all 16)
                   output shortint train_label_dec[9:0]); 
	always_comb
		begin
            for (int i = 0; i < 10; i++) 
            begin
                train_label_dec[i] = 0; 
		end 
			
		case(train_label_b)
			//9th index represents digit 0.
			4'b0000: train_label_dec[9] = 1000; //0
			4'b0001: train_label_dec[8] = 1000; //1
			4'b0010: train_label_dec[7] = 1000; //2
			4'b0011: train_label_dec[6] = 1000; //3
			4'b0100: train_label_dec[5] = 1000; //4
			4'b0101: train_label_dec[4] = 1000; //5
			4'b0110: train_label_dec[3] = 1000; //6
			4'b0111: train_label_dec[2] = 1000; //7
			4'b1000: train_label_dec[1] = 1000; //8
			4'b1001: train_label_dec[0] = 1000; //9
		endcase
		end 
endmodule


/* Calculates the derivative of MSE*/
module MSE_derivative(input shortint train_label_dec[9:0],
                      input shortint output_test[9:0], //output reg from multiply module
                      output shortint result[9:0]);
	always_comb
	begin
		for (int i = 0; i < 10; i++) 
		begin
			result[i] = output_test[i] - train_label_dec[i]; //assigns to array
		end 
	end 
endmodule

/* State machine to calculate gradients
 *
 * Inputs: start_stream - Indicate if its a pixel we want
 *         start_train_sw - SW[17], set to HIGH to train
 *         start_pixel - Indicate the start of an image 
 *
 * Outputs: new_weights - new weights for each row of pixels (784)
 *          W_en - Write enable to save to OCM
 */
module train_state_machine(input clk, 
                           input reset, 
                           input start_stream, 
                           input shortint result_prev[9:0],
                           input pixel, 
                           input start_train_sw, 
                           input start_pixel,
                           input shortint weights[9:0],  
                           output shortint new_weights[9:0],
                           output logic W_en);
	
	shortint delta_w[9:0]; 
	logic [1:0] delay; //multiple_acc IP requires 3 cycle latency to show result
	logic aclr3, clock0, accum_start, done, enable_clk; //signals from mult_acc module
	logic [15:0] datab; 
	logic [9:0] counter; //counter to count to 784 pixels -- can make output signal if needed by any other modules 
	shortint debug_delta[9:0];

	enum logic [3:0] {WAIT, WAIT_IM, MULTIPLY_3, UPDATE, DONE, REST, FIRST_PIX} state, next_state; 

	//insert some kind of state machine here for computation 
	always_ff @ (posedge clk)
		begin
			if(reset)  //active high 
				state <= REST; 
			else 
				state <= next_state; 
		end

	always_ff @ (posedge clk) //control signals 
	begin
		case(state)
			WAIT: 
			begin	
				counter <= 1; 
				delay <= 0;
				W_en <= 1'b0;
			end

			MULTIPLY_3: //this state is for the 3 cycle delay
			begin
				delay <= delay + 1'b1; //increment delay count 
			end
			
			UPDATE:
			begin
				counter <= counter + 1'b1;
                //Write enable HIGH next clk cycle to sync with new_weights
                W_en <= 1'b1;
				for (int i = 0; i < 10; i++) 
				begin 
					new_weights[i] <= weights[i] - debug_delta[i]; //assigns to array
				end 
			end		

            DONE:
                //Set W_en back to 0 since its a latch.
                W_en <= 1'b0;
		endcase 
	end
		
	always_comb
	begin
	for (int i = 0; i < 10; i++)
		begin
            //division by 1000 as our learning rate
			debug_delta[i] <= delta_w[i] / 1000; 
		end
	end 
	
	always_comb //state machine for next state logic 
	begin
		next_state = state; 
		case(state)
			REST: //wait for KEY[2] press and SW17 to be HIGH
			if (start_train_sw)
				next_state = FIRST_PIX;
				
			FIRST_PIX: //wait for signal start_pix to indicate the start of the picture
			begin
				if (start_pixel)
					next_state = WAIT;
			end	
			WAIT: 
			begin
				if(start_stream) //active high 
					next_state = MULTIPLY_3; 
			end
			
			WAIT_IM:
			begin
				if (start_stream)
					next_state = MULTIPLY_3;
			end

			MULTIPLY_3:
			begin
				if(delay == 2) //once delay reaches full latency
					next_state = UPDATE; 
			end

			UPDATE: //now multiply outputs are available 
				next_state = DONE;
			
			DONE: 
			begin
				if (counter == 784)
				begin
					//prevent multiple run per key press
					if (start_train_sw)
						next_state = REST; 
					else
						next_state = DONE;
				end
				else
					next_state = WAIT_IM;
			end
						
		endcase
	end

	always_comb //logic assignments
	begin
		done = 1'b0; //done is low 
		aclr3 = 1'b0; //clear is low
		datab = 16'b0; //default of datab input is 0 
		accum_start = 1'b0; //never want to accumulate 
		enable_clk = 1'b1;
		
		case(state)
			WAIT: 
			begin
				aclr3 = 1'b1; //clear in wait state
			end

			MULTIPLY_3: 
			begin	
				enable_clk = 1'b1;
				datab[0] = pixel; 
			end

			DONE:
			begin
				done = 1'b1; //set done flag high 
			end
		endcase
	end
	assign clock0 = clk; //synchronize 
 
	mult_accum ma0(.*, .dataa(result_prev[0]), .result(delta_w[0])); 
	mult_accum ma1(.*, .dataa(result_prev[1]), .result(delta_w[1])); 
	mult_accum ma2(.*, .dataa(result_prev[2]), .result(delta_w[2])); 
	mult_accum ma3(.*, .dataa(result_prev[3]), .result(delta_w[3])); 
	mult_accum ma4(.*, .dataa(result_prev[4]), .result(delta_w[4])); 
	mult_accum ma5(.*, .dataa(result_prev[5]), .result(delta_w[5])); 
	mult_accum ma6(.*, .dataa(result_prev[6]), .result(delta_w[6])); 
	mult_accum ma7(.*, .dataa(result_prev[7]), .result(delta_w[7])); 
	mult_accum ma8(.*, .dataa(result_prev[8]), .result(delta_w[8])); 
	mult_accum ma9(.*, .dataa(result_prev[9]), .result(delta_w[9])); 
endmodule 
