module sram_controller (input clk,
                        input reset_n,
                        input display_complete,
                        output logic sram_wren,
                        output logic addr_incre);
			
		enum logic [1:0] {WAIT, GET_DATA, WR_0, WR_1} state, next_state;
		
		always_ff @ (posedge clk or negedge reset_n)
		begin
            if (~reset_n)
                state <= WAIT;
            else
                state <= next_state;
		end
		
		always_comb 
		begin
			sram_wren = 1'b0;
			addr_incre = 1'b0;
			next_state = state;
			case (state) 
			
				WAIT: 
				if (display_complete)
					next_state = GET_DATA;
					
				GET_DATA:
				begin
					next_state = WR_0;
				end
				//give 2 cycles to write to address before incrementing it	
				WR_0:
				begin
					next_state = WR_1;
					sram_wren = 1'b1;
				end
				WR_1: 
				begin
					next_state = WAIT;
					sram_wren = 1'b1;
					addr_incre = 1'b1;
				end
			endcase
		end
endmodule
