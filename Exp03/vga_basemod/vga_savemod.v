module vga_savemod
(
    input RESET,
    input [1:0]iClock,
	 input [1:0]iEn, // [1]Write ,[0]Read
    input [15:0]iData,
	 output [15:0]oData
);
   parameter XSIZE = 10'd512;
	
   (* ramstyle = "no_rw_check , m9k" *) reg [15:0] RAM [1023:0];
	reg [9:0]RP;
	reg [15:0]D1;
	
   always @ ( posedge iClock[0] or negedge RESET ) 
	    if( !RESET )
		     begin 
			      RP <= 10'd0; 
					D1 <= 16'd0; 
			  end
		 else if( iEn[0] )
		     begin 
					RP <= RP + 1'b1; 
					D1 <= RAM[RP];
			  end
		 else
		     begin
					RP <= 10'd0;
					D1 <= 16'd0;
			  end
		    		  
	reg [9:0]WP;
	
	always @ ( posedge iClock[1] or negedge RESET )
	    if( !RESET ) 
		     WP <= 10'd0;
		 else if( iEn[1] )
		     begin
					WP <= (WP == XSIZE -1 ) ? 10'd0 : WP + 1'b1;
		         RAM[ WP ] <= iData;
			  end
		     
   assign oData = D1;

endmodule
