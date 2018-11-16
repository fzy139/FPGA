module graphic_demo 
(
    input CLOCK, RESET,

	 // SDRAM
	 output S_CLK,
	 output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE,
	 output [12:0]S_A, 
    output [1:0]S_BA,
    output [1:0]S_DQM,
    inout [15:0]S_DQ,
	 
	 // VGA
	 output VGA_HSYNC, VGA_VSYNC,
	 output [15:0]VGAD
);
    wire CLOCK_MAIN,CLOCK_SDRAM,CLOCK_VGA;
	 
	 pll_module	U0
	 (
	    .inclk0 ( CLOCK ),
	    .c0 ( CLOCK_MAIN ), // 100Mhz, -210 degeree
	    .c1 ( CLOCK_SDRAM ), // 100Mhz, SDRAM
	    .c2 ( CLOCK_VGA )   // 25Mhz, VGA
	 );
	 
	 wire [1:0]DoneU1;
	 wire [15:0]DataU1;

	 graphic_submod U1
	 (
	     .RESET( RESET ),
	     .S_CLK ( S_CLK ),
		  .S_CKE( S_CKE ),
		  .S_NCS( S_NCS ),
		  .S_NRAS( S_NRAS ),
		  .S_NCAS( S_NCAS ),
		  .S_NWE( S_NWE ),
		  .S_A( S_A ),
		  .S_BA( S_BA ),
		  .S_DQM( S_DQM ),
		  .S_DQ( S_DQ ),
		  .VGA_HSYNC( VGA_HSYNC ), 
	     .VGA_VSYNC( VGA_VSYNC ) ,
		  .iClock( { CLOCK_MAIN,CLOCK_SDRAM,CLOCK_VGA } ),
		  .VGAD( VGAD ),
		  .iCall( isCall ),      // [1]Write , [0]Read
	     .oDone( DoneU1 ),        
		  .iAddr( D1 ),          // [23:0]
        .iData( D2 ),          // [15:0]
		  .oData( DataU1 )
	 );
	 
	 reg [7:0]i;
	 reg [1:0]isCall;
	 reg [23:0]D1;
	 reg [15:0]D2;
	 reg [8:0]CX;
	 reg [14:0]CY;
	 
	 always @ ( posedge CLOCK_MAIN or negedge RESET )
	     if( !RESET )
		      begin 
				    i <= 8'd0;
				    isCall <= 2'b00;
					 D1 <= 24'd0;
					 D2 <= 16'd0;
					 CX <= 9'd0;
					 CY <= 15'd0;
				end
		  else
		      case( i )
				   
					0:
					if( DoneU1[1] ) begin isCall[1] <= 1'b0; i <= i + 1'b1; end
					else begin isCall[1] <= 1'b1; D1 <= { CY,CX }; D2 <= {5'd31,6'd0,5'd0 }; end//16'hAAAA;end//{5'd31,6'd0,5'd0 }; end // 7'd0,CX
					
					1:
					if( CX == (80*1) -1 ) begin i <= i + 1'b1; end
					else begin CX <= CX + 1'b1; i <= 8'd0; end
					
					2:
					if( DoneU1[1] ) begin isCall[1] <= 1'b0; i <= i + 1'b1; end
					else begin isCall[1] <= 1'b1; D1 <= { CY,CX }; D2 <= {5'd31,6'd0,5'd31 }; end//16'hBBBB; end//{5'd31,6'd0,5'd31 } ; end // 7'd0,CX
					
					3:
					if( CX == (80*2) -1 ) begin i <= i + 1'b1; end
					else begin CX <= CX + 1'b1; i <= 8'd2; end
					
					4:
					if( DoneU1[1] ) begin isCall[1] <= 1'b0; i <= i + 1'b1; end
					else begin isCall[1] <= 1'b1; D1 <= { CY,CX }; D2 <= {5'd0,6'd0,5'd31 } ; end//16'hCCCC; end //{5'd0,6'd0,5'd31 } ; end // 7'd0,CX
					
					5:
					if( CX == (80*3) -1 ) begin i <= i + 1'b1; end
					else begin CX <= CX + 1'b1; i <= 8'd4; end
					
					6:
					if( DoneU1[1] ) begin isCall[1] <= 1'b0; i <= i + 1'b1; end
					else begin isCall[1] <= 1'b1; D1 <= { CY,CX }; D2 <= {5'd0,6'd31,5'd0 } ; end//16'hDDDD; end //{5'd0,6'd31,5'd0 } ; end // 7'd0,CX
					
					7:
					if( CX == (80*4) -1 ) begin CX <= 9'd0; i <= i + 1'b1; end
					else begin CX <= CX + 1'b1; i <= 8'd6; end
					
					8:
					if( CY == 240 -1 ) begin CY <= 14'd0; i <= i + 1'b1; end
					else begin CY <= CY + 1'b1; i <= 8'd0; end
					
					9:
					i <= 8'd0;
				
				endcase
	 
endmodule
