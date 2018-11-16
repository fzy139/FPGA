module sdram_ctrlmod
(
	input CLOCK,
	input RESET,
	input [2:0]iCall, // [1]Write, [0]Read
	output [2:0]oDone,
	output [4:0]oCall,  // [3]Write, [2]Read, [1]A.Ref, [0]Initial
	input iDone
);
   parameter GREAD = 4'd1, WRITE = 4'd4, READ = 4'd7, REFRESH = 4'd10, INITIAL = 4'd11;
	parameter TREF = 11'd782;
	
	reg [3:0]i;
	reg [10:0]C1;
	reg [4:0]isCall; //[3]Write [2]Read [1]A.Refresh [0]Initial
	reg [2:0]isDone;
	
	always @ ( posedge CLOCK or negedge RESET )
	    if( !RESET )
		     begin
		         i <= INITIAL;          // Initial SDRam at first 
		         C1 <= 11'd0;
					isCall <= 5'b00000;
					isDone <= 3'b000;
			  end
		 else 
		     case( i )
			  
					0: // IDLE
					if( C1 >= TREF ) begin C1 <= 11'd0;  i <= REFRESH; end
					else if( iCall[2] ) begin C1 <= TREF; i <= GREAD; end
					else if( iCall[1] ) begin C1 <= C1 + 1'b1; i <= WRITE; end 
				   else if( iCall[0] ) begin C1 <= C1 + 1'b1; i <= READ; end 
               else begin C1 <= C1 + 1'b1; end

               /***********************/
					
					1: // CRead
					if( iDone ) begin isCall[4] <= 1'b0; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					else begin isCall[4] <= 1'b1; C1 <= C1 + 1'b1; end
					
					2:
					begin isDone[2] <= 1'b1; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					
					3:
					begin isDone[2] <= 1'b0; C1 <= C1 + 1'b1; i <= 4'd0; end
				    
					/***********************/ 
					 
				   4: //Write 
					if( iDone ) begin isCall[3] <= 1'b0; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					else begin isCall[3] <= 1'b1; C1 <= C1 + 1'b1; end
					
					5:
					begin isDone[1] <= 1'b1; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					
					6:
					begin isDone[1] <= 1'b0; C1 <= C1 + 1'b1; i <= 4'd0; end
					
					/***********************/
				    
				   7: // Read
					if( iDone ) begin isCall[2] <= 1'b0; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					else begin isCall[2] <= 1'b1; C1 <= C1 + 1'b1; end
					
					8:
					begin isDone[0] <= 1'b1; C1 <= C1 + 1'b1; i <= i + 1'b1; end
					
					9:
					begin isDone[0] <= 1'b0; C1 <= C1 + 1'b1; i <= 4'd0; end
					
					/***********************/
					
					
					10: // Auto Refresh 
					if( iDone ) begin isCall[1] <= 1'b0; i <= 4'd0; end
				   else begin isCall[1] <= 1'b1; end
					
					/***********************/
					
					11: // Initial 
					if( iDone ) begin isCall[0] <= 1'b0; i <= 4'd0; end
				   else begin isCall[0] <= 1'b1; end
								
			  endcase
			  
	assign oDone = isDone;
	assign oCall = isCall;
	
endmodule
