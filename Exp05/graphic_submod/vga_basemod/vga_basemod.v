module vga_basemod
(
    input RESET,
    output VGA_HSYNC, VGA_VSYNC,
	 output [15:0]VGAD,
	 input [1:0]iClock,  // 100M, 25Mhz
	 input iEn,
	 input [15:0]iData,
	 output [10:0]oTag
);
	 wire [15:0]DataU1;
	 
	 vga_savemod U1
	 (
		 .RESET( RESET ),
		 .iClock( iClock ),
		 .iEn( { iEn,EnU2 } ),  // [1]write, [0]Read
		 .iData( iData ),
		 .oData( DataU1 )
	 );
	 
	 wire EnU2;
	 
	 vga_funcmod U2    // 640 * 480 @ 60Hz
	 (
	   .CLOCK( iClock[0] ), 
	   .RESET( RESET ),
		.oEn( EnU2 ),
		.iData( DataU1 ),
	   .VGA_HSYNC( VGA_HSYNC ), 
	   .VGA_VSYNC( VGA_VSYNC ),
      .VGAD( VGAD ),
		.oTag( oTag )
	 );			 
	   
endmodule
