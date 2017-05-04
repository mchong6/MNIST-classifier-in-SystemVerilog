/*Simulates downsampling of an image for testbench*/

module pix_sim(input logic clk, reset,
		output logic [4:0] H_cont, V_cont,
		output logic start_stream,
		output logic start_pixel);

	reg [3:0] count;
	logic clk_16;
	assign clk_16 = ~count[3];
	assign start_pixel = H_cont == 1 && V_cont == 1? 1:0;
	
	//counter to get a 16 times slower clk for bit stream simulation
	always_ff@(posedge clk or posedge reset)
	begin
		if (reset)
			count <= 0;
		else
			count <= count + 1;
	end
	
	always_ff@(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			H_cont <= 1;
			V_cont <= 1;
		end
		else if (count == 0)
		begin
			start_stream <= 1;
			if (H_cont < 28)
				H_cont <= H_cont + 1;
			else
				H_cont <= 1;
				
			if (H_cont == 28)
			begin
				if (V_cont < 28)
					V_cont <= V_cont + 1;
				else
					V_cont <= 1;
			end
		end
		else
			start_stream <= 0;
	end

endmodule
