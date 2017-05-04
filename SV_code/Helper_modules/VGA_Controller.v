module	VGA_Controller(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						iGrey,
						iBW,
						oRequest,
						start_stream, //indicate which pixel to choose to get 28x28
                        start_pixel, //indicate the start of a new frame
						Sample_V_Cont,
						Sample_H_Cont,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,
						oVGA_CLOCK,
						//	Control Signal
						iCLK,
						iRST_N,
                        itoggle);

`include "VGA_Param.h"

//	Host Side
input		[7:0]	iRed;
input		[7:0]	iGreen;
input		[7:0]	iBlue;
input		[7:0]	iGrey;
input		[7:0]	iBW;
output	reg			oRequest;
output   reg        start_stream;
output              start_pixel;
//	VGA Side
output	reg	[7:0]	oVGA_R;
output	reg	[7:0]	oVGA_G;
output	reg	[7:0]	oVGA_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg	[4:0]	Sample_H_Cont;
output 	reg 	[4:0]	Sample_V_Cont;
output				oVGA_SYNC;
output				oVGA_BLANK;
output				oVGA_CLOCK;
//	Control Signal
input				iCLK;
input				iRST_N;
input               itoggle;

//	Internal Registers and Wires
reg		[9:0]		H_Cont;
reg		[9:0]		V_Cont;
reg		[9:0]		Cur_Color_R;
reg		[9:0]		Cur_Color_G;
reg		[9:0]		Cur_Color_B;
wire				mCursor_EN;
wire				mRed_EN;
wire				mGreen_EN;
wire				mBlue_EN;

assign 	truncated_area = H_Cont >= (X_START+96) && H_Cont < (X_START+H_SYNC_ACT-96)
			&& V_Cont >= (Y_START+16) && V_Cont < (Y_START+V_SYNC_ACT-16) ? 1:0;
			
assign start_pixel = H_Cont == 1 && V_Cont == 1 ? 1:0;

reg [3:0] H_counter;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		//start from 0 because synchronous with start_stream
		//first start_stream count will be 1
		Sample_H_Cont <= 0;
		Sample_V_Cont <= 0;
	end
	else if (H_counter == 1 && truncated_area && V_Cont % 16 ==0)
	begin
		if (Sample_H_Cont < 28)
			Sample_H_Cont <= Sample_H_Cont + 1;
		else
			//reset to 1 so next start_stream starts at 1
			Sample_H_Cont <= 1;

		if (Sample_H_Cont == 28)
		begin
			if (Sample_V_Cont < 28)
				Sample_V_Cont <= Sample_V_Cont + 1;
			else
				Sample_V_Cont <= 1;
		end
	end
end

//Choose a pixel every 16 horizontal and vertical count.
always@(posedge iCLK)
begin
	if (H_counter == 1 && truncated_area && V_Cont % 16 ==0 )
		start_stream <= 1;
	else
		start_stream <= 0;
end
//Horizontal down sample counter
always@(posedge iCLK or negedge iRST_N)
begin
	if (!iRST_N)
		H_counter <= 4'd0;
	else if (truncated_area)
		H_counter <= H_counter + 1;
end

			
assign	oVGA_BLANK	=	oVGA_H_SYNC & oVGA_V_SYNC;
assign	oVGA_SYNC	=	1'b0;
assign	oVGA_CLOCK	=	iCLK;

//for bw/rgb mode
reg [1:0] state;


//start stream ignores the backporch/front porch so we truncate only correct pixels	
/*always @(posedge iCLK) begin			
	if (truncated_area)
		start_stream = 1;
	else
		start_stream = 0;
end
*/
/*assign start_stream = (H_Cont >= (X_START+96) && H_Cont < (X_START+H_SYNC_ACT-96)
			&& V_Cont >= (Y_START+16) && V_Cont < (Y_START+V_SYNC_ACT-16)) ? 1:0;
*/			
//
//sensitive to state or clk change. If use @(*) here, it breaks!
always @(posedge iCLK) begin			
    if (H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
		V_Cont>=Y_START 	&& V_Cont<Y_START+V_SYNC_ACT)
    begin
		if (start_stream)
			begin
				oVGA_R = iBW;
            oVGA_G = iBW;
            oVGA_B = iBW;
			end
		else
		begin
        if (state == 0)
        begin
            oVGA_R = iRed;
            oVGA_G = iGreen;
            oVGA_B = iBlue;
        end
        else if (state == 1)
        begin
            oVGA_R = iGrey;
            oVGA_G = iGrey;
            oVGA_B = iGrey;
        end
        else
        begin
            oVGA_R = iBW;
            oVGA_G = iBW;
            oVGA_B = iBW;
        end
		 end
    end
    else
    begin
        oVGA_R = 0;
        oVGA_G = 0;
        oVGA_B = 0;
    end
end

always@(posedge itoggle)
begin
    if(itoggle)
        state <= (state + 1) % 3;
end
//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
    begin
        oRequest	<=	0;
    end
	else
    begin
        if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
            V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
        oRequest	<=	1;
    else
        oRequest	<=	0;
    end
end

//	H_Sync Generator, Ref. 25.175 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		oVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC
		)
		oVGA_H_SYNC	<=	0;
		else
		oVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		oVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC)
			oVGA_V_SYNC	<=	0;
			else
			oVGA_V_SYNC	<=	1;
		end
	end
end

endmodule
