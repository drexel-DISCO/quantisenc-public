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
// File     	: syn_access.v
// Desc     	: This is an implementation of address generation for accessing synaptic weights from bmem.
// 		          It generates a trigger pulse, whenever the there is a change in spike input.
// 		          Using this trigger, the accumulator is reset (implemented inside bmem).
// 		          This module also generates the address for synaptic memory.
// 		          The module is instantiated inside a layer. 
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module syn_access #(
	parameter FANIN 	    = 256, 		    //fanin of the layer
	localparam ADDR_WIDTH 	= $clog2(FANIN)	//synaptic memory address width
)(
	input rst,			                    //reset
	input memclk,			                //clock
	input [FANIN-1:0] inspk,	            //input spikes from pre-synaptic connections
	output outspk,			                //output spike to the bmem and LIF module
	output rst_acc,			                //reset for the accumulator
	output rd_en,			                //read enable
	output [ADDR_WIDTH-1:0] rd_addr         //address to read from the synaptic memory 	
);
	

	reg [FANIN-1:0] inspk_q1, inspk_q2, inspk_q3;	//delayed version of the spikes
	reg cnt_en;				                        //enable counting of memory read accesses
	reg [ADDR_WIDTH-1:0] addr_cnt;		            //address counter

	//delay spikes by two clock cycles and check if the input has changed.
	always @(posedge memclk or posedge rst) begin
		if (rst) begin
			inspk_q1 <= 0;
			inspk_q2 <= 0;
			inspk_q3 <= 0;
		end
		else begin
			inspk_q1 <= inspk;
			inspk_q2 <= inspk_q1;
			inspk_q3 <= inspk_q2;
		end
	end

	//address counter: a countdown counter counting from FANIN-1:0.
	always @(posedge memclk or posedge rst) begin
		if (rst) begin
			cnt_en 	 <= 1'b0;
			addr_cnt <= 0;
		end
		else begin
			if (rst_acc) begin
				cnt_en 	 <= 1'b1;
				addr_cnt <= FANIN-1;
			end
			else begin
				if (addr_cnt > 0) begin
					cnt_en   <= 1'b1;
					addr_cnt <= addr_cnt - 1;
				end
				else begin
					cnt_en   <= 1'b0;
				end
			end
		end
	end

	//all output
	assign outspk 	= |inspk_q3;			        //OR of all spikes.
	assign rst_acc 	= |(~inspk_q3 & inspk_q2);	    //see if any of the spike input has changed. The accumulator needs to be reset if the input spikes changes.
	assign rd_en 	= cnt_en & inspk_q3[addr_cnt];	//read enable.
        assign rd_addr 	= addr_cnt;			        //the address counter can be used as the memory read address.	

endmodule
