/* -----------------------------------------------------------------------------
MIT License

Copyright (c) 2023 Drexel Distributed, Intelligent, and Scalable COmputing (DISCO) Lab

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
// Author   	: Anup Das
// Email    	: anup.das@drexel.edu
// Date     	: June 03, 2024
// File     	: qmul.v
// Desc     	: This is an implementation of qmultiplier. 
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

//uncomment the following line to enable overflow detection
//`define OVERFLOW_DET

// (Q,N) = (12,16) => 1 sign-bit + 3 integer-bits + 12 fractional-bits = 16 total-bits
//                    |S|III|FFFFFFFFFFFF|
// The same thing in A(I,F) format would be A(3,12)
module qmult #(
	//Parameterized values
	parameter Q = 12,
	parameter N = 16
	)(
	input 	[N-1:0]	a,
	input	[N-1:0]	b,
	output 	[N-1:0] q_result	//output quantized to same number of bits as the input
	);
	 
	// The underlying assumption, here, is that both fixed-point values are of the same length (N,Q)
	// Because of this, the results will be of length N+N = 2N bits
	// This also simplifies the hand-back of results, as the binimal point 
	// will always be in the same location
	
	wire [2*N-1:0]	f_result;					//Multiplication by 2 values of N bits requires a 
	wire [N-1:0]	result;						//Multiplication by 2 values of N bits requires a 
	wire overflow;							    //Overflow
	wire underflow;							    //Underflow signal
									            //Register that is N+N = 2N deep
	wire [N-1:0]	multiplicand;
	wire [N-1:0]	multiplier;
	wire [N-1:0]	a_2cmp, b_2cmp;
	wire [N-2:0]	quantized_result,quantized_result_2cmp;
	
	assign a_2cmp = {a[N-1],{(N-1){1'b1}} - a[N-2:0]+ 1'b1};  	//2's complement of a
	assign b_2cmp = {b[N-1],{(N-1){1'b1}} - b[N-2:0]+ 1'b1};  	//2's complement of b
	
	assign multiplicand = (a[N-1]) ? a_2cmp : a;              
	assign multiplier   = (b[N-1]) ? b_2cmp : b;
    
	assign result[N-1] = a[N-1]^b[N-1];                      	//Sign bit of output would be XOR or input sign bits
	assign f_result = multiplicand[N-2:0] * multiplier[N-2:0]; 	//We remove the sign bit for multiplication
	assign quantized_result = f_result[N-2+Q:Q];               	//Quantization of output to required number of bits
	assign quantized_result_2cmp = {(N-1){1'b1}} - quantized_result[N-2:0] + 1'b1;  	//2's complement of quantized_result
	assign result[N-2:0] = (result[N-1]) ? quantized_result_2cmp : quantized_result; 	//If the result is negative, we return a 2's complement representation 
    												//of the output value
	assign overflow = (f_result[2*N-2:N-1+Q] > 0) ? 1'b1 : 1'b0;

	wire cond1, cond2, cond3;

	assign cond1 = (|quantized_result) 	? 1'b0 : 1'b1;	//check if the absolute result is 0
	assign cond2 = (multiplier > 0) 	? 1'b1 : 1'b0;	//check if the multiplier is greater than 0
	assign cond3 = (multiplicand > 0)	? 1'b1 : 1'b0;	//check if the multiplicand is greater than 0

	assign underflow = (&{cond1,cond2,cond3}) ? 1'b1 : 1'b0;
	//case ({cond1,cond2,cond3})
	//	3'b111: assign underflow = 1'b1;
	//	default: assign underflow = 1'b0;
	//endcase
	wire [N-1:0] q_overflow;
	wire [N-1:0] q_underflow;
	localparam MSB = N-1;

	assign q_overflow       = overflow  ? { 1'b0, {MSB{1'b1}} } : result;
	assign q_underflow      = underflow ? { 1'b1, {MSB{1'b1}} } : q_overflow;
	assign q_result         = q_underflow;


endmodule
