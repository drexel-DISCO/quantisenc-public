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
// File     	: bmem.v
// Desc     	: This is an implementation of a 1D array of memory.  
//                This array holds the synaptic memory of all incoming connections to a neuron.
//                Here, the block RAM can be used to implement synaptic memory.
//                The actual implementation consists of pipelined memory access using a fast clock.
//                Memory contents are accessed one at a time.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

`include "defines.vh"

module bmem #(
	//configurable parameters
	parameter FANIN 		        = 256,	//FANIN of the neuron
	parameter INTEGER_PRECISION 	= 3,	//integer precision
	parameter DECIMAL_PRECISION	    = 4,	//decimal precision
	//local parameters
	localparam WT_PRECISION = (1+DECIMAL_PRECISION),			        //precision of synaptic weights
	localparam PRECISION 	= (1+INTEGER_PRECISION+DECIMAL_PRECISION),	//precision of state variables (= 1 + integer_precision + decimal_precision)
	localparam ADDR_WIDTH 	= $clog2(FANIN)	                            //address width for the memory addresses of fanin of each neuron. 
)(
	input rst,				            //reset
	input memclk,				        //memory access & mac clock
	input spkclk,				        //spike clock
	input wr_en,				        //write enable for writing to the synaptic weight memory
	input [ADDR_WIDTH-1:0] wr_addr,		//synaptic memory address for write
	input [WT_PRECISION-1:0] wr_data,	//synaptic weight
	input rd_en,				        //read enable for reading from synaptic weight memory
	input [ADDR_WIDTH-1:0] rd_addr,		//synaptic memory address for read
	input rst_acc,				        //reset for the accumulator
	input inspk,				        //input spikes from pre-synaptic connections (ORed of all spikes)
	output outspk,				        //output spike to the LIF module
	output [PRECISION-1:0] activation	//output activation to the LIF module
);

	reg [WT_PRECISION-1:0] rd_data;
	reg inspk_q, rd_en_q;

	//instantiate the memory
	(* ram_style = "block" *) reg [WT_PRECISION-1:0] mem [FANIN-1:0];

	//access the memory
	always @(posedge memclk) begin
		if (wr_en) begin
			mem[wr_addr] <= wr_data;
		end
		
		rd_data <= mem[rd_addr];
		//if (rd_en) begin
		//	rd_data <= mem[rd_addr];
		//end
	end

	//delay the spike to be in sync with memory read
	always @(posedge memclk or posedge rst) begin
		if (rst) begin
			inspk_q <= 0;
		end
		else begin
			inspk_q <= inspk;
		end
	end

	//delay the read enable to capture the correct data from the memory
	always @(posedge memclk or posedge rst) begin
		if (rst) begin
			rd_en_q <= 0;
		end
		else begin
			rd_en_q <= rd_en;
		end
	end

	//mac operation
	reg [PRECISION-1:0] psum;
	wire [PRECISION-1:0] psum_int;

	always @(posedge memclk or posedge rst) begin
		if (rst) begin
			psum <= 0;
		end
		else begin
			if (rst_acc) begin
				psum <= 0;
			end
			else begin
				if (rd_en_q) begin
					psum <= psum_int;
				end
			end
		end
	end

	//quantized adder
	localparam INT_PRECISION = PRECISION - WT_PRECISION;

	qadd #(
		.N(PRECISION)
	) psum_inst(
		.a(psum),
		.b({ {INT_PRECISION{rd_data[WT_PRECISION-1]}},rd_data }),
		.q_result(psum_int)
	);

	//output assignment
	localparam PRECISION_PLUS_ONE = (PRECISION + 1);
	synchronizer #(
		.N(PRECISION_PLUS_ONE)
	) ff_sync(
		.rst(rst),
		.clk(spkclk),
		.in( {inspk_q,psum} ),
		.out( {outspk,activation} )
	);

endmodule
