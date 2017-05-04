/* Converts 10bits RGB to 8bits RGB
 *
 * Inputs: iRed/Green/Blue - input pixels
 *
 * Outputs: oRed/Green/Blue - output pixels
 */
module shiftpixel(input logic[9:0]	iRed,
                  input logic[9:0]	iGreen,
                  input logic[9:0]	iBlue,
                  output logic[7:0] oRed,
                  output logic[7:0] oBlue,
                  output logic[7:0] oGreen);
                        
    assign oRed = iRed >> 2;
    assign oGreen = iGreen >> 2;
    assign oBlue = iBlue >> 2;
                        
endmodule

/* Converts image from gray to B/W
 *
 * Inputs: in_pixel - input pixels
 *
 * Outputs: out_pixel - output pixels
 */
module gray2bw(input logic [7:0] in_pixel,
               output logic [7:0] out_pixel);
					
	always_comb begin
		if (in_pixel > 8'd100)
			out_pixel = 8'd255;
		else
			out_pixel = 8'd0;
	end
endmodule

/* Converts image from RGB to B/W
 *
 * Inputs: iRed/Green/Blue - input pixels
 *
 * Outputs: grey_pixel 
 *          bw_pixel
 */
module imageprocess(input logic[9:0] iRed,
                    input logic[9:0] iGreen,
                    input logic[9:0] iBlue,
                    output logic[7:0] grey_pixel,
                    output logic[7:0] bw_pixel);
						
assign grey_pixel = ((iRed >> 2) + (iGreen >> 1) + (iBlue>>2) >> 2);			
gray2bw     black_unit(.in_pixel(grey_pixel), .out_pixel(bw_pixel));

endmodule

/*********FOLLOWING FUNCTIONS MIGRATED TO VGA CONTROLLER ***********/

////truncate 640 x 480 to 448 x 448 so we can downsample it to 28 x 28
////note 1st pixel comes at count 1, not count 0
//module truncate(input clk, reset, start_stream,
                //output logic accept);
					
    //parameter H_total = 640;
    //parameter V_total = 480;
    //logic [9:0] H_cont, V_cont, H_cont_in, V_cont_in;

    //always_ff@(posedge clk or negedge reset)
    //begin
        //if (~reset)
        //begin
            //H_cont <= 10'd1;
            //V_cont <= 10'd1;
        //end
        //else
        //begin
            //H_cont <= H_cont_in;
            //V_cont <= V_cont_in;
        //end
    //end

    //always_comb
    //begin
        //H_cont_in = H_cont;
        //V_cont_in = V_cont;
        //if (start_stream)
        //begin
        //if (H_cont < H_total)
            //H_cont_in = H_cont + 1;
        //else 
            //// reset to 1 because 1st pixel comes at count 1
            //H_cont_in = 1;
            
        //if (V_cont < V_total)
        //begin
            //if (H_cont == H_total)
                //V_cont_in = V_cont + 1;
        //end
        //// we start V from 1 too  
        //else if (H_cont == H_total)
            //V_cont_in = 1;	
        //end
    //end

    ////truncate the border away to get 448 x 448
    //assign accept = (H_cont <= 96 || H_cont >= 545 || V_cont <= 16 || V_cont >= 465) ? 0:1;
//endmodule


////use this to downsample 448x448 to 16x16
//module down_sample2(input clk, reset, in_accept,
                    //output logic out_accept,
                    //output logic[4:0] oH_cont,
                    //output logic[4:0] oV_cont,
                    //output logic image_ready);
                    
	 ////in accept chooses which pixel so we get 448 x488
	 ////out accept tells us which pixel to choose so we get 28 x 28
	 //parameter H_total = 28;
	 //parameter V_total = 28;
	 //logic [4:0] H_cont, V_cont, H_cont_in, V_cont_in;
	 ////16 counter to know when to sample. would it overflow back to 0??
	 //logic [3:0] counter, counter_in;
 
	//always_ff@(posedge clk or negedge reset)
	//begin
		//if (~reset)
		//begin
			////start counting from 1
			//H_cont <= 5'd1;
			//V_cont <= 5'd1;
			//counter <= 4'd0;
		//end
		//else
		//begin
			//H_cont <= H_cont_in;
			//V_cont <= V_cont_in;
			//counter <= counter_in;
			//[>
			////choose one of the 448 x 448 pixel
			//if (in_accept)
			////increment counter everytime we in_accept a pixel.
			//counter <= counter + 1;
			////its the 1st of 16 bits, we choose it*/
		//end
	//end
			
	//always_comb
	//begin
		//out_accept = 0;
		//H_cont_in = H_cont;
		//V_cont_in = V_cont;
		//counter_in = counter;
		//if (in_accept)
		//begin
			//counter_in = counter + 1;
			//if (counter == 15)
			//begin
				//out_accept = 1;
				//if (H_cont < H_total)
					//H_cont_in = H_cont + 1;
				//else 
					//// reset to 1 because 1st pixel comes at count 1
					//H_cont_in = 1;

				//if (V_cont < V_total)
				//begin
					//if (H_cont == H_total)
						//V_cont_in = V_cont + 1;
				//end
				//else 
				//begin
					//// we start V from 1 too
					//if (H_cont == H_total)
						//V_cont_in = 1;
				//end
			//end
		//end
	//end
	//always_comb begin
		//if (H_cont == H_total && V_cont == V_total)
			//image_ready = 1;
		//else   
			//image_ready = 0;
	//end
//endmodule

//module down_sample(input clk, reset, in_accept,
                    //output logic out_accept,
                    //output logic[4:0] oH_cont,
                    //output logic[4:0] oV_cont,
                    //output logic image_ready);
	
	//logic [3:0] counter;
	////assign out_accept = (counter == 0 && in_accept) ? 1 : 0;
	
	//always_ff@(posedge clk or negedge reset)
	//begin
		//if (~reset)
			////start counting from 1
			//counter <= 4'd0;
		//else if (in_accept)
		//begin
			//counter <= counter + 1;
			//if (counter == 0)
				//out_accept <= 1;
			//else 
				//out_accept <= 0;
		//end
		//else
			//out_accept <= 0;
		
	//end
	
	//assign oH_cont = 0;
	//assign oV_cont = 0;
	//assign image_ready = 0;
	
//endmodule						  
