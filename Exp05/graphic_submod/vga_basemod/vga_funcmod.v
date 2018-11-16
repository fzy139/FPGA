module vga_funcmod
(
    input CLOCK, RESET,
	 output VGA_HSYNC, VGA_VSYNC,
	 output [15:0]VGAD,
	 output oEn,
	 input [15:0]iData,
	 output [10:0]oTag 
);
    parameter FRAME_DELAY = 8'd60;
    parameter SA = 10'd96, SB = 10'd48, SC = 10'd640, SD = 10'd16, SE = 10'd800;
	 parameter SO = 10'd2, SP = 10'd33, SQ = 10'd480, SR = 10'd10, SS = 10'd525;
	 parameter XSIZE = 10'd320, YSIZE = 10'd240, XOFF = 10'd0, YOFF = 10'd0; 
	 
    reg [9:0]CH;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      CH <= 10'd0;
		  else if( CH == SE -1 )
		      CH <= 10'd0;
		  else 
		      CH <= CH + 1'b1;
				
	 reg [9:0]CV;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      CV <= 10'd0;
		  else if( CV == SS -1 )
		      CV <= 10'd0;
		  else if( CH == SE -1 )
		      CV <= CV + 1'b1;
				
	 reg [7:0]CF;
	 reg isON;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      begin
		          CF <= 8'd0;
					 isON <= 1'b0; 
				end
		  else if( CF == FRAME_DELAY -1 ) // delay 1s
		      begin
				    CF <= CF;
				    isON <= 1'b1;
				end
		  else if( CV == SS -1 && !isON )
		      begin
				    CF <= CF + 1'b1;
				end

	 reg H;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      H <= 1'b1;
		  else if( CH == SE -1 ) 
		      H <= 1'b0;
		  else if( CH == SA -1 ) 
		      H <= 1'b1;
				
	 reg V;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      V <= 1'b1;
		  else if( CV == SS -1 ) 
		      V <= 1'b0;
		  else if( CV == SO -1 ) 
		      V <= 1'b1;
		      
	 /***************/			
	 
	 wire isX = ( (CH >= SA + SB + XOFF -1 ) && ( CH <= SA + SB + XOFF + XSIZE -1) ) && isON;
	 wire isY = ( (CV >= SO + SP + YOFF -1   ) && ( CV <= SO + SP + YOFF + YSIZE -1 ) ) && isON;
	 
	 wire isStart = (CH == SA + SB + XOFF -1 -2 );
	 wire isStop = (CH == SA + SB + XOFF + XSIZE -1 -2);
	 
	 reg isUpdate;
	 reg [9:0]CY;
	 always @ ( posedge CLOCK or negedge RESET ) // Update
	     if( !RESET )
		      begin isUpdate <= 1'b0; CY <= 10'd0; end
		  else if( isY && CH == 1 ) 
		      begin isUpdate <= 1'b1; CY <= (CV - (SO + SP + YOFF) +1); end //+1 修正
		  else 	
		      isUpdate <= 1'b0;
	
	 reg [15:0]D1;
	 reg isEn;
	 
	 always @ ( posedge CLOCK or negedge RESET ) // Reading
	     if( !RESET )
		      begin
		          D1 <= 16'd0;
					 isEn <= 1'b0;
			   end
		  else 
		      begin 
				     if( isStart && isY  ) isEn <= 1'b1; 
				  	 else if( isStop && isY ) isEn <= 1'b0;
					 
					 // Read data from savemod
					 
					 D1 <= isX && isY ? iData : 16'd0;		 
				end 

   assign { VGA_HSYNC, VGA_VSYNC } = { H,V };	
	assign VGAD = D1; 	
	assign oEn = isEn;
	assign oTag[10] = isUpdate;
	assign oTag[9:0] =  CY;
	 
endmodule
