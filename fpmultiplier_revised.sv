//-----------------------------------------------------
// File Name   : fpmultiplier_revised.sv
// Function    : IEEE 724 32 bit multiplier
// Version: 2,  
// Author:  ks6n19
// Last rev. 13-01-21
//-----------------------------------------------------
module fpmultiplier_revised(output logic [31:0] product, output logic ready,
               input logic [31:0] a, input logic clock, nreset);

	enum {idle,start,loada, loadb,waitin, multip, waitin2,sign_comp, normalisation, rounding, exponent_add, removebias, stopped } state  ;
	 logic sign_bit_a ; 
	 logic sign_bit_b ; 
     logic [7:0]sign_exponent_a ;
	 logic [7:0]sign_exponent_b ;
     logic [23:0]mantissa_a ;
	 logic [23:0]mantissa_b ;
     logic [47:0]multip_P ;
	 logic [23:0]X ;
	 logic [23:0]Y ;
	 logic sign_bit_p ;
	 logic [22:0] mantissa_p ;
	 logic [7:0] sign_exponent_p ;
     
		always_ff @(posedge clock , negedge nreset)       		// Always_ff block 
		
			begin : SEQ
				if(!nreset)
					state <= idle  ;
				else   
                    unique case (state)
					
					idle :  begin 
							 state <= start	;
							 ready <= '1 ;
					        end  
					
					start : begin  
								ready <= '0 ;
								state <= loada ;
						     end    
					

                    loada : begin                                        // sign_bit ,sign_exponent , mantissa 
                                sign_bit_a <= a[31] ;
                                sign_exponent_a <= a[30:23]  ;
                                mantissa_a <= {1'b1 , a[22:0]} ;
								state <= loadb ;
                            end 

                    loadb : begin 
                                sign_bit_b <= a[31] ;
                                sign_exponent_b <= a[30:23] ;
                                mantissa_b <= {1'b1 , a[22:0]} ;
								state <= waitin ;
                            end 
					waitin : begin  
							   X <=  mantissa_a ;
							   Y <=  mantissa_b ;
							   state <= multip ;
							 end				

					multip : begin
									 multip_P[47:0] <= X * Y ;
									
									state <= waitin2 ;
							  end 
					waitin2 :  state <= sign_comp ;
							  
				sign_comp :  	 begin 	
							 begin
								 if ( sign_bit_a ^ sign_bit_b == 1'b1) 
									
									sign_bit_p <= 1'b1  ;
								
								 else
									
									sign_bit_p <= 1'b0 ;
								end
							state <= exponent_add ;
						end 	

				
				exponent_add  :     begin 
							sign_exponent_p[7:0] <=  sign_exponent_a + sign_exponent_b ;
								state <= normalisation ;
						end 	

			normalisation :    begin
							 if (multip_P[46] == 1'b0)
								begin
									multip_P <= multip_P >> 1;
									sign_exponent_p[7:0] <= sign_exponent_p[7:0] + 7'b0000001 ;
							    end 	
								state <= rounding ;	
							   end 			

			     rounding :    begin 
									begin
				
											mantissa_p[22:0] <= multip_P[45:23] ;
									end
								  state <= removebias ;
								end  
			

			    removebias:     begin                                                    // removing bias and incrementing the exponent for the normalisation part
							state <= stopped ;
							 sign_exponent_p[7:0] <= sign_exponent_p[7:0] - 7'b1111111 ;
							 

							end		

				  stopped :   begin 
						product <= {sign_bit_p , sign_exponent_p , mantissa_p} ;
								state <= start ; ready <= '1 ;
						if (sign_exponent_p[7:0] == 8'b1111111 )
							begin 		
							$display("NaN") ;
							end
						if ( a == '0 )
							begin 
							 product <= '0 ;
							end 	
							
						
								
								
							  end 	 
					endcase 		  
			end	
		
        
		
endmodule					