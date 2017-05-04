//weights.sv
//this module is to be used in multiplication to access the weights of the corresponding pixel value 

module weights_controller(input clk,
                          input [4:0] H_count, V_count,
                          input W_en,	//read or write
                          input	shortint weights_in[9:0],
                          output shortint weights_out[9:0]); 
			
	logic [79:0] weights_matrix[784]; 
	initial 
	begin
		 $readmemh("weights.txt", weights_matrix); 
	end
	
	logic [9:0] index; //index of row of weights
	logic [79:0] weight_row; 
	assign weight_row = weights_matrix[index]; 
	assign index = ((V_count * 28) + H_count - 29) >= 0 ?((V_count * 28) + H_count - 29): 0; //H_count, V_count starts from 1. 

	always_ff@(posedge clk)
	begin
		//update weights
		if (W_en)
		begin
			weights_matrix[index] <= {weights_in[9][7:0],
												 weights_in[8][7:0],
												 weights_in[7][7:0],
												 weights_in[6][7:0],
												 weights_in[5][7:0],
												 weights_in[4][7:0],
												 weights_in[3][7:0],
												 weights_in[2][7:0],
												 weights_in[1][7:0],
												 weights_in[0][7:0]};
			
			//weights_matrix[index] = 80'b1;
		end
	end

	always_comb 
	begin
		//need to split every 8 bits for each value in array --> weights_out vector = 80 bits
		//SEXT
		weights_out[9] = {{8{weight_row[79]}}, weight_row[79:72]}; 
		weights_out[8] = {{8{weight_row[71]}}, weight_row[71:64]};
		weights_out[7] = {{8{weight_row[63]}}, weight_row[63:56]};
		weights_out[6] = {{8{weight_row[54]}}, weight_row[55:48]};
		weights_out[5] = {{8{weight_row[47]}}, weight_row[47:40]};
		weights_out[4] = {{8{weight_row[39]}}, weight_row[39:32]};
		weights_out[3] = {{8{weight_row[31]}}, weight_row[31:24]};
		weights_out[2] = {{8{weight_row[23]}}, weight_row[23:16]};
		weights_out[1] = {{8{weight_row[15]}}, weight_row[15:8]};
		weights_out[0] = {{8{weight_row[7]}}, weight_row[7:0]};
	end 
endmodule 
