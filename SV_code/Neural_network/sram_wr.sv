module rdbw (input clk,
				 input reset_n,
				 input ctr_en,
				 output [9:0] bw_rdaddr);
				 
	
		always_ff @ (posedge clk or negedge reset_n)
		begin
				if (~reset_n)
					bw_rdaddr <= 10'h0;
				else
				begin
					if (ctr_en)
					begin 
						// range 0 - 783. 782 + 1 = 783
						if (bw_rdaddr < 783)
							bw_rdaddr <= bw_rdaddr + 1;
						else 
							bw_rdaddr <= 10'h0;
					end
				end
		end
		
endmodule
