module vga_demo
(
    input CLOCK,RESET,
	 
	 output VGA_HSYNC, VGA_VSYNC,
	 output [15:0]VGAD
);
    wire CLOCK_MAIN,CLOCK_SDRAM,CLOCK_VGA;
	 
	 pll_module	U0
	 (
	    .inclk0 ( CLOCK ),
	    .c0 ( CLOCK_MAIN ),   // 100Mhz, -210 degree
	    .c1 ( CLOCK_SDRAM ),  // 100Mhz, SDRAM
	    .c2 ( CLOCK_VGA )     // 25Mhz, VGA
	 );

    vga_funcmod U1
	 (
	    .CLOCK( CLOCK_VGA ),
		 .RESET( RESET ),
		 .VGA_HSYNC( VGA_HSYNC ), 
	    .VGA_VSYNC( VGA_VSYNC ),
       .VGAD( VGAD )
	 );

endmodule
