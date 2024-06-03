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
// File     	: decoder.v
// Desc     	: This is an implementation of a simple decoder. 
// 		          This module receives input configuration for the neurons of the design.
// 		          Configuration is serially loaded into an N-bit configuration register.
// 		          N is programmable via the parameters.vh file.
// 		          All neuron parameters are decoded inside this module.
// 		          Current congiguration register setting is as follows.
//		          CFG = OO|LL|XX|DD|GG|VV|RR
//		          OO = GPIO configuration
//		          LL = Layer that needs to be monitored.
//		          XX = Neuron of the layer that needs to be monitored.
//		          DD = Decay rate of vmem.
//		          GG = Grow rate of vmem.
//		          VV = VTH.
//		          RR = Reset mechanism of neuron.
//		          This module is also used to decode synaptic memory adderesses.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module decoder #(
	parameter ADDR_WIDTH	= 32,			//memory address bits
	parameter DATA_WIDTH	= 32,			//memory data bits
	parameter CFG_REG	    = 5,			//number of configuration registers
	parameter PRECISION 	= 8			    //precision of state variables
)(
	//input
	input rst,					            //reset
	input clk,					            //clock
	input wr_en,					        //write enable for configuration registers
	input [ADDR_WIDTH-1:0] wr_addr,			//synaptic memory/configuration address
	input [DATA_WIDTH-1:0] wr_data,			//synaptic memory/configuration data
	//output neuron configuration
	output [PRECISION-1:0] vth,			    //neuron threshold voltage
	output [PRECISION-1:0] decay_rate,		//rate of decay of activation with time
	output [PRECISION-1:0] grow_rate,		//rate of growth of activation with input spike
	output [PRECISION-1:0] reset_mechanism,	//neuron reset mechanism
	output [PRECISION-1:0] vrest,			//neuron resting potential
	output [PRECISION-1:0] refractory_period,	//neuron refractory period
	//output monitor configuration
	output [DATA_WIDTH-1:0] layer_to_monitor,	//index of the layer that needs to be monitored
	output [DATA_WIDTH-1:0] neuron_to_monitor	//index of the neuron that needs to be monitored
);

	//write to configuration register
	reg [DATA_WIDTH-1:0] config_reg [CFG_REG-1:0];	//configuration registers
	integer i;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (i=0;i<CFG_REG;i=i+1) begin
				config_reg[i] <= 0;
			end
		end
		else begin
			if (wr_en) begin
				config_reg[wr_addr] <= wr_data;
			end
		end
	end

	//neuron configurations
	assign vth		        = config_reg[0];	//output vth
	assign decay_rate	    = config_reg[1];	//output decay_rate
	assign grow_rate	    = config_reg[2];	//output grow_rate
	assign vrest 		    = config_reg[3];	//output vrest
	assign reset_mechanism 	= config_reg[4];	//output reset mechanism
	assign refractory_period= config_reg[5];	//output refractory period
	assign layer_to_monitor	= config_reg[6];	//output neuron ID to monitor
	assign neuron_to_monitor= config_reg[7];	//output layer ID to monitor

endmodule
