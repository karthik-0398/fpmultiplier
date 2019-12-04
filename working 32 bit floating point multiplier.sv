module fpmultiplier(output logic [31:0] product, output logic ready,
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
									
									state <= waitin2 ;
							  end 
					waitin2 :  state <= sign_comp ;
							  
				sign_comp :  	state <= exponent_add ;
				
				exponent_add  :     state <= normalisation ;

			normalisation :    begin
								
								state <= rounding ;	
							   end 			

			     rounding :    begin 
									begin
				
											mantissa_p[22:0] <= multip_P[46:23] ;
									end
								  state <= removebias ;
								end  
			

			    removebias:     state <= stopped ;

				  stopped :   begin 
								product <= {sign_bit_p , sign_exponent_p , mantissa_p} ;
								state <= start ;
							  end 	 
					endcase 		  
			end	
		
        
		
		always_comb 
			begin :COM                                         // COM block 
				   
				    
				  casex (state) 
					
					start  : begin 
								
						multip_P ='0 ;
						sign_exponent_p ='0 ;
						sign_exponent_p  ='0;
						 end 
					
					multip: begin                                                  //multiplying mantissas of load A and load B 
							  multip_P = X * Y ;

							end 
					
				sign_comp : begin                                                  // setting sign bit of product 
							   begin
								 if ( sign_bit_a ^ sign_bit_b == 1'b1) 
									
									sign_bit_p = 1'b1  ;
								
								 else
									
									sign_bit_p = 1'b0 ;
								end
							end 	
							  
			exponent_add : begin                                                     // adding exponents of load_A and load_B

			 				 sign_exponent_p =  sign_exponent_a + sign_exponent_b ;
	
							end 				 

		   normalisation :  begin                                                    // shift mantissa of multip_P bits left by 1 
							  if (multip_P[46] == 1'b0)
								begin
									multip_P = multip_P >> 1;
									sign_exponent_p = sign_exponent_p + 1 ;
							    end 
							end

		     

			   removebias : begin                                                    // removing bias and incrementing the exponent for the normalisation part

							 sign_exponent_p = sign_exponent_p - 127 ;
							 

							end					 
							
				  stopped : begin                                                   // after ready gets asserted ,  start=> load_A => load_B
							
							$display ("%f\n " , product);

							 end 
							 
	            endcase		
			end
endmodule					
