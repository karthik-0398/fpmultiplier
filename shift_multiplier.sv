/////////////////////////////////////////////////////////////////////
// Design unit: sequencer
//            :
// File name  : sequencer.sv
//            :
// Description: Code for M4 Lab exercise
//            : Outline code for sequencer
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Author     : 
//            : School of Electronics and Computer Science
//            : University of Southampton
//            : Southampton SO17 1BJ, UK
//            : 
//
// Revision   : Version 1.0 
/////////////////////////////////////////////////////////////////////

module sequencer #( parameter N = 4'b0100 ) (input logic start, clock, Q0, n_rst,
 output logic add, shift, ready, reset); 
logic [N-1 :0]count = N ; 
enum {Idle, Adding, Shifting, Stopped } present_state, next_state ;

  
  always_ff@(posedge clock, negedge n_rst)    //defining behavior at posedge and negedge of clock
            
		begin : SEQ             
		   if (~n_rst)
                       present_state <= Idle;	 
				
                   else 
			begin
			if(next_state == Adding ) 
                        	count <= count - 1;
			present_state <= next_state ;	
		     	end
		end

  always_comb 
    begin : COM        


    reset = '0 ;
    shift = '0;
    ready = '0;
    add = '0;


     unique case (present_state)

       Idle : 
         begin            
           reset = '1;
               if (start) 
                 next_state = Adding ;
               else  
                 next_state = present_state;
         end                


       Adding : 
         begin               
                if(Q0)
                   begin           
                       add = '1;
                       next_state = Shifting ;
                   end    
                 else 
                       next_state = Shifting ;       
 
         end              


       Shifting :
          begin             
            shift = '1;
                if (count > 0)
                    next_state = Adding ;
                else
                    next_state = Stopped ;
         end              


       Stopped : 
          begin           
             ready = '1;
                if (start)
                     next_state = Idle ;
                else 
                     next_state = Stopped ; 
   
         end          
 


       endcase
    end  
endmodule

      
              
             