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
// File     	: synchronizer.v
// Desc     	: This is an implementation of cross domain data synchronizer.
// 		          This implements double flip-flop synchronization.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module synchronizer #(
	//Parameterized values
	parameter N = 8
	)(
	input rst,
	input clk,
	input  [N-1:0]	in,	//input
	output [N-1:0] 	out	//output
	);

	reg [N-1:0] in_q1, in_q2;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			in_q1 	<= 0;
			in_q2	<= 0;
		end
		else begin
			in_q1	<= in;
			in_q2	<= in_q1;
		end
	end

	assign out = in_q2;

endmodule
