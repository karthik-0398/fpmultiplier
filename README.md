# fpmultiplier
This design achieves a 32-bit floating-point multiplication complying with IEEE 724 binary32 format.
The multiplier was written in SystemVerilog and simulated in ModelSim and synthesised in Quartus Prime. 
It gives a result utilising rounding via truncation to give acceptable precision for real life applications.  
It includes cases to check for Not a number (NaN) and signed zero numbers. 
The product that is computed after the multiplication is normalised and adjusted to comply with IEEE 724 standards. 
The design achieves the multiplication in 140ns at the positive edge of the clock pulse.
