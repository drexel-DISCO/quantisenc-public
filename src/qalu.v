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
// File     	: qalu.v
// Desc     	: This is an implementation of quantized arithmatic and logic unut (ALU).
// 		          It performs q = a + b (add) or q = a - b (sub). 
// 		          Selection between add and sub is controlled via the sel signal.
// 		          Control Signals: 0: quaantized add
// 		          		   1: quantized subtract
// 		          The control logic is not fully implemented yet. This is simply an adder.
// 		          The output is controlled using an enable signal.
// 		          en = 1: q = a
// 		          Else, q = a + b
// 		          This also generates an output pos indicating if the sum of a+b is positive.
// 		          This signal can be used as a comparator bit.
// 		          Spifically, if we provide 2's complement to input b, then q = a - b.
// 		          In this case, the pos signal indicates if a-b > 0, i.e., a > b.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module qalu #(
	//Parameterized values
	parameter N = 16
	)(
	input  [N-1:0]	a,	//input 1
	input  [N-1:0]	b,	//input 2
	input 		en,	    //enable for the alu
	input		sel,	//select between quantized adder vs. subtractor
	output [N-1:0] 	q,	//output quantized to same number of bits as the input
	output 		pos	    //output bit indicating if the result is positive
	);
	
	wire [N-1:0] sum;	//temporary result

	//instantiate the adder
	qadd #(
		.N(N)
	) qadd_inst (
		.a(a),
		.b(b),
		.q_result(sum)
	);

	assign q 	= en ? sum : a;	            //final output after applying the mux
	assign pos	= (|sum) ? ~q[N-1] : 0;

endmodule
