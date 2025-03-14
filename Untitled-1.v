//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010 Gandhi Puvvada, EE-Systems, VSoE, USC
//
// This design exercise, its solution, and its test-bench are confidential items.
// They are University of Southern California's (USC's) property. All rights are reserved.
// Students in our courses have right only to complete the exercise and submit it as part of their course work.
// They do not have any right on our exercise/solution or even on their completed solution as the solution contains our exercise.
// Students would be violating copyright laws besides the University's Academic Integrity rules if they post or convey to anyone
// either our exercise or our solution or their solution. 
// 
// THIS COPYRIGHT NOTICE MUST BE RETAINED AS PART OF THIS FILE (AND ITS SOLUTION AND/OR ANY OTHER DERIVED FILE) AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////
//
// A student would be violating the University's Academic Integrity rules if he/she gets help in writing or debugging the code 
// from anyone other than the help from his/her lab partner or his/her teaching team members in completing the exercise(s). 
// However he/she can discuss with felllow students the method of solving the exercise. 
// But writing the code or debugging the code should not be with the help of others. 
// One should never share the code or even look at the code of others (code from classmates or seniors 
// or any code or solution posted online or on GitHub).
// 
// THIS NOTICE OF ACADEMIC INTEGRITY MUST BE RETAINED AS PART OF THIS FILE (AND ITS SOLUTION AND/OR ANY OTHER DERIVED FILE) AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////



// EE457 
// ee457_lab3_4bit_ALU Lab
// Written by Nasir Mohyuddin, Gandhi Puvvada 
// June 17, 2010, Jan 31, 2025
// 
// 4-Bit ALU Module
// This file contains both modules:
// 1. a 1-bit ALU building block (based on figure C.5.9 of the 4th edition of  
//    the textbook, which is same as figure B.5.9 of the 3rd edition), and
// 2. a 4-bit ALU built by instantiating 4 of the above building blocks and 
//    adding needed glue logic for SLT implementation (based on figure C.5.12 of the 
//    4th edition of our textbook, which is same as figure B.5.12 of the 3rd edition)
//-------------------------------------------------------------------------------

// This file contains two modules:  the alu_1_bit  and   the alu_4_bit

// 1-bit ALU building block alu_1_bit
`timescale 1 ns / 100 ps

module alu_1_bit (A, B, CIN, LESS, AINV, BINV, Opr, RESULT, COUT, ADD_R);

input A, B, CIN, LESS, AINV, BINV;
input [1:0] Opr;
output RESULT, ADD_R, COUT;

reg RESULT, COUT, ADD_R;
         
always @(*) // same as   always @(A, B, Ainv, Binv, CIN, Opr, LESS) 
  
	  begin  : combinational_logic // named procedural block
	  // local declarations in the named procedural block
	  reg RESULT_AND, RESULT_OR, RESULT_ADD_SUB, RESULT_SLT;
	  reg Am, Bm; // Am is the A at the output of the mux controlled by AINV; Similarly Bm
  
		Am = AINV ? ~A : A;  	//  fill-in   ~A : A    or  A : ~A  
		Bm = BINV ? ~B : B;	//  fill-in   ~B : B    or  B : ~B 

		// fill-in the following lines using Am, Bm, CIN
		RESULT_AND = Am & Bm;
		RESULT_OR  = Am | Bm,;
		ADD_R = Am + Bm;
		RESULT_ADD_SUB = ADD_R;
		RESULT_SLT = LESS;
		COUT   =  (CIN & Am) | (CIN & Bm) | (Am & Bm);
		
		case (Opr)
				0	: // 2'b00 for the SLT A, B instruction ( if A < B, RESULT =1)
				  begin
					RESULT = RESULT_SLT; 
				  end
				1	: //2'b01  Arithmetic addition or subtract depending on the value of BNEG        
				  begin
					RESULT = RESULT_ADD_SUB; 
				  end 
				  
				2	: // 2'b10 Logical OR Function 
					begin
					RESULT = RESULT_OR;
					end
				3	: // 2'b11 Logical AND Function 
					begin
					RESULT = RESULT_AND;
					end
						
		  endcase
	   end 
endmodule //alu_1_bit

//-------------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module alu_4_bit (A, B, AINV, BNEG, Opr, RESULT, OVERFLOW, ZERO, COUT);

input [3:0] A, B;
input  AINV, BNEG;
input [1:0] Opr;

output[3:0] RESULT;
output OVERFLOW, ZERO, COUT;

//LOCAL SIGNALS;
wire COUT1, COUT2, COUT3, COUT4; // the four carry-out signals from the four ALU slices
wire BINV, SET, LESS_0;
wire [3:0] ADD_R;

// Equate both of these to the input BNEG so that you negate B by doing (B' + 1)
assign BINV = BNEG				; // fill-in this line
assign CIN = BNEG				; // fill-in this line // CIN is the Carry-In to the alu0 slice and as well as Carry-In for the 4-bit ALU 

assign COUT = COUT4				; // fill-in this line This is COUT of the 4-bit adder. Is it COUT3 or COUT4?
assign OVERFLOW = COUT3 ^ COUT4				; // fill-in this line
assign SET = ADD_R[3]; // Adder result from the alu3 (the most-significant alu slice)
assign LESS_0 = SET ^ OVERFLOW				 ; // fill-in this line // Think carefully about this
// Please corect the next line!!!!
assign ZERO = 	( (~RESULT[0]) & (~RESULT[1]) & (~RESULT[2]) & (~RESULT[3]) );  // correct this line !!!! *****

// Instantiate the alu_1_bit four times. Use LESS_0 
// Follow the order carefully since we are using positional association (positional mapping)
// module alu_1_bit (A, B, CIN, LESS, AINV, BINV, Opr, RESULT, COUT, ADD_R);
alu_1_bit alu0 (A[0], B[0], 1'b0, 1'b0, AINV, BINV, Opr, RESULT[0], COUT1, ADD_R[0]);	// fill-in this line
alu_1_bit alu1 (A[1], B[1], COUT1, 1'b0, AINV, BINV, Opr, RESULT[1], COUT2, ADD_R[1]);
alu_1_bit alu2 (A[2], B[2], COUT2, 1'b0, AINV, BINV, Opr, RESULT[2], COUT3, ADD_R[2]);
alu_1_bit alu3 (A[3], B[3], COUT3, 1'b0, AINV, BINV, Opr, RESULT[3], COUT4, ADD_R[3]);
        
endmodule // alu_4_bit