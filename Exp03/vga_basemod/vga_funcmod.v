module vga_funcmod
(
    input CLOCK, RESET,
	 output VGA_HSYNC, VGA_VSYNC,
	 output [15:0]VGAD
);
    parameter SA = 10'd96, SB = 10'd48, SC = 10'd640, SD = 10'd16, SE = 10'd800;
	 parameter SO = 10'd2, SP = 10'd33, SQ = 10'd480, SR = 10'd10, SS = 10'd525;
	 parameter XSIZE = 10'd128, YSIZE = 10'd128, XOFF = 10'd256, YOFF = 10'd176; 
	 
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
	 
	 wire isX = ( (CH >= SA + SB + XOFF -1 ) && ( CH <= SA + SB + XOFF + XSIZE -1) );
	 wire isY = ( (CV >= SO + SP + YOFF -1  ) && ( CV <= SO + SP + YOFF + YSIZE -1 ) );
	 
	 reg [15:0]D1;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      D1 <= 16'd0;
		  else  
				D1 <= isX && isY ? {5'd31,6'd63,5'd31} : 16'd0;		  

   assign { VGA_HSYNC, VGA_VSYNC } = { H,V };	
	assign VGAD = D1; 	
	 
endmodule
