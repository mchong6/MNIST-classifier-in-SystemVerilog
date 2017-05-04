/* Does matrix multiplication and returns prediction
 *
 * Inputs: start_stream - Indicate if its a pixel we want
 *         weights_in - Current weights of pixel row
 *
 * Outputs: classification - Prediction of label
 *          output_test - Output for forward propagation
 */
module multiply(input logic clk, 
                input logic reset, 
                input logic pixel, 
                input logic start_stream,
                input shortint weights_in[9:0],
                output logic [3:0] classification,
                output shortint output_test[9:0]);

	matmux10 multiply_unit(.weight(weights_in), 
                           .classification, 
                           .output_test, 
                           .*); 
endmodule 


/* State machine for multiplication
 *
 * Inputs: start_stream - Indicate if its a pixel we want
 *         weight - Current weights of pixel row
 *
 * Outputs: classification - Prediction of label
 *          output_test - Output for forward propagation
 */
module matmux10(input shortint weight[9:0], 
				input pixel, 
				input clk, 
                input reset, 
                input start_stream,
				output logic [3:0] classification, 
                output shortint output_test[9:0]); 

	logic [1:0] delay; //multiple_acc IP requires 3 cycle latency to show result
	logic aclr3, clock0; //signals from mult_acc module
	logic [15:0] datab; 
	logic [9:0] counter; //counter to count to 784 pixels -- can make output signal if needed by any other modules 
	logic accum_start; // tells the mult-accum to accumulate
	logic enable_clk;
	shortint output_reg[9:0];
	logic [3:0] comparator_output;
	enum logic [2:0] {WAIT, WAIT2, MULTIPLY, MULTIPLY_DELAY, DONE, COMPARE} state, next_state; 


	always_ff @ (posedge clk)
		begin
			if(reset)  //active high 
				state <= WAIT; 
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
				end

				MULTIPLY: //stays in this state until counter reaches 784 
				begin
				 	counter <= counter + 1'b1; //increment counter 
				end 

				MULTIPLY_DELAY: //this state is for the 3 cycle delay
				begin
					delay <= delay + 1'b1; //increment delay count 
				end
				
				COMPARE:
                begin
					classification <= comparator_output;
                    //saves the output for backprop
                    output_test <= output_reg;
                end
			endcase 
		end

	always_comb //state machine for next state logic 
	begin
		next_state = state; 
		case(state)
			WAIT: 
			begin
				if(start_stream) //active high 
					next_state = MULTIPLY_DELAY; 
			end
			
			WAIT2:
				begin
					if (start_stream)
						next_state = MULTIPLY;
				end
			MULTIPLY: 
			begin
					next_state = DONE; //go to next state to wait for delay before output appears
			end

			MULTIPLY_DELAY:
			begin
				if(delay == 2) //once delay reaches full latency
					next_state = DONE; 
			end

			DONE: //now multiply outputs are available 
			begin
				if (start_stream)
					next_state = DONE; //gets stuck in this state 
				else
				begin
					if (counter == 784)
						next_state = COMPARE;
					else
						next_state = WAIT2;
				end
			end
			
			COMPARE:
			begin
				next_state = WAIT;
			end
		endcase
	end

	always_comb //logic assignments
	begin
		aclr3 = 1'b0; //clear is low
		datab = 16'b0; //default of datab input is 0 
		accum_start = 1'b1;
		enable_clk = 1'b0;

		case(state)
			WAIT: 
			begin
				aclr3 = 1'b1; //clear in wait state
			end

			MULTIPLY: 
			begin
				enable_clk = 1'b1;
				datab[0] = pixel; 
				accum_start = 1'b1;
			end
			
			MULTIPLY_DELAY: 
			begin	
				enable_clk = 1'b1;
				datab[0] = pixel; 
				accum_start = 1'b1;
			end
		endcase
	end
	assign clock0 = clk; //synchronize 
 
	mult_accum ma0(.*, .dataa(weight[0]), .result(output_reg[0])); 
	mult_accum ma1(.*, .dataa(weight[1]), .result(output_reg[1])); 
	mult_accum ma2(.*, .dataa(weight[2]), .result(output_reg[2])); 
	mult_accum ma3(.*, .dataa(weight[3]), .result(output_reg[3])); 
	mult_accum ma4(.*, .dataa(weight[4]), .result(output_reg[4])); 
	mult_accum ma5(.*, .dataa(weight[5]), .result(output_reg[5])); 
	mult_accum ma6(.*, .dataa(weight[6]), .result(output_reg[6])); 
	mult_accum ma7(.*, .dataa(weight[7]), .result(output_reg[7])); 
	mult_accum ma8(.*, .dataa(weight[8]), .result(output_reg[8])); 
	mult_accum ma9(.*, .dataa(weight[9]), .result(output_reg[9])); 
	largest_reg comparator_unit(.clk, .reset, .result(output_reg), .classification(comparator_output)); 
	
endmodule 

/* Compares output nodes and returns index of highest node
 *
 * Inputs: result - output of forward propagation
 *
 * Outputs: classification - Prediction of label
 */
module largest_reg(input clk, 
                   input reset, 
                   input shortint result[9:0], 
                   output logic [3:0] classification); 

	//holds the digit classification;
	logic r0, r1, r2, r3, r4, r5, r6, r7, r8, r9; //these are the comparison values

	//compare module returns alb = 1 if dataa < datab

	compare c0(.dataa(result[9]), .datab(result[8]), .alb(r0)); //if r1 = 1, result[1] is larger, else result[0]
	compare c1(.dataa(result[7]), .datab(result[6]), .alb(r1));
	compare c2(.dataa(result[5]), .datab(result[4]), .alb(r2));
	compare c3(.dataa(result[3]), .datab(result[2]), .alb(r3));
	compare c4(.dataa(result[1]), .datab(result[0]), .alb(r4));

    logic [3:0] a0, a1, a2, a3, a4, a5, a6, a7, a8; 

	assign a0 = r0 ? 8 : 9; //if r0 is high, result[0] < result[1] so choose 1; else choose 0 
	assign a1 = r1 ? 6 : 7;
	assign a2 = r2 ? 4 : 5;
	assign a3 = r3 ? 2 : 3;
	assign a4 = r4 ? 0 : 1;

	compare c5(.dataa(result[a1]), .datab(result[a0]), .alb(r5));
	compare c6(.dataa(result[a3]), .datab(result[a2]), .alb(r6));

	assign a5 = r5 ? a0 : a1; 
	assign a6 = r6 ? a2 : a3;

	compare c7(.dataa(result[a5]), .datab(result[a4]), .alb(r7));

	assign a7 = r7 ? a4 : a5;

	compare c8(.dataa(result[a7]), .datab(result[a6]), .alb(r8)); 

	assign a8 = r8 ? a6 : a7; 
	//a8 now holds largest register value
	assign classification = 4'd9 - a8; 
endmodule
