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
// File     	: qadd.v
// Desc     	: This is an implementation of a signed quantized adder. 
// 		          The output is desiggned to saturate upon positive and negative_overflows.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module qadd #(
	//Parameterized values
	parameter N = 16
	)(
	input  [N-1:0]	a,
	input  [N-1:0]	b,
	output [N-1:0] q_result	//output quantized to same number of bits as the input
	);

	localparam MSB = N - 1;			//this is the MSB bit
	localparam N_MINUS_2 = N - 2;	//this is the N - 2

	wire [N-1:0] result;		    //result
	wire extra_bit;			        //extra bit
	wire positive_overflow;		    //positive_overflow bit
	wire negative_overflow;		    //negative_overflow bit

	assign {extra_bit, result} 	= {a[MSB], a} + {b[MSB], b};		    //get the extra bit and also the results
	assign positive_overflow 	= ({extra_bit, result[MSB]} == 2'b01 );	//compute positive_overflow
	assign negative_overflow 	= ({extra_bit, result[MSB]} == 2'b10 );	//compute negative_overflow
	
	//saturate results upon positive_overflow/negative_overflow
	wire [N-1:0] q_positive_overflow;
	wire [N-1:0] q_negative_overflow;

	assign q_positive_overflow 	= positive_overflow  ? { 1'b0, {MSB{1'b1}} } : result;
	assign q_negative_overflow	= negative_overflow ? { 1'b1, {N_MINUS_2{1'b0}}, 1'b1 } : q_positive_overflow;
	assign q_result 		= q_negative_overflow;

endmodule
