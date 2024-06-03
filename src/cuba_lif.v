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
// File     	: cuba_lif.v
// Desc     	: This is an implementation of a single lif neuron with its pre-synaptic weights.
//                The module instantiates bmem, which is  a memory array of FANIN * PRECISION bits.
//                Essentially, these are synaptic weights of each pre-synaptic connections to the LIF neuron.
//                The top module also instantiates the lif module, which is the main code for a leaky integrate-and-fire neuron.
//                The weights from the memory (bmem) are input to the LIF.
// -----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module cuba_lif #(
	//configurable parameters
	parameter FANIN 		        = 256,			//fanin
	parameter INTEGER_PRECISION	    = 3,			//integer precision
	parameter DECIMAL_PRECISION 	= 4,			//fraction precision
	//local parameters
	localparam WT_PRECISION 	    = (1+DECIMAL_PRECISION),			        //precision for synaptic weights
	localparam PRECISION 		    = (1+INTEGER_PRECISION+DECIMAL_PRECISION),	//precision for state variables
	localparam ADDR_WIDTH		    = $clog2(FANIN)		                        //address width for the memory addresses of fanin of each neuron. 
)(
	input rst,				                //common reset
	input memclk,				            //memory clock
	input spkclk,				            //spike clock
	//neuron parameters from congiguration registers
	input [PRECISION-1:0] vth,		        //neuron threshold voltage
	input [PRECISION-1:0] decay_rate,	    //membrane decay rate
	input [PRECISION-1:0] grow_rate,	    //membrane grow rate
	input [PRECISION-1:0] vrest,		    //neuron resting potential
	input [PRECISION-1:0] reset_mechanism,	//neuron reset mechanism
	input [PRECISION-1:0] refractory_period,//neuron refractory period
	//memory write
	input wr_en,				            //write enable to synaptic memory
	input [ADDR_WIDTH-1:0] wr_addr,		    //write address to synaptic memory
	input [WT_PRECISION-1:0] wr_data,	    //write data (weights) to synaptic memory
	//memory read
	input rd_en,				            //read enable for synaptic memory
	input [ADDR_WIDTH-1:0] rd_addr,		    //read address for synaptic memory
	//accumulator clear
	input rst_acc,				            //clear signal for the accumulator
	//input spike
	input inspk,				            //spike input from pre-synaptic connections
	//output
	output outspk,				            //spike output from lif
	output [PRECISION-1:0] vmem		        //membrane potential of the lif 		
);

	//signals
	wire int_spk;
	wire [PRECISION-1:0] int_activation;

	//instantiate the bmem
	bmem #(
		.FANIN(FANIN),
		.INTEGER_PRECISION(INTEGER_PRECISION),
		.DECIMAL_PRECISION(DECIMAL_PRECISION)
	) bmem_dut(
		.rst(rst),
		.memclk(memclk),
		.spkclk(spkclk),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data),
		.rd_en(rd_en),
		.rd_addr(rd_addr),
		.rst_acc(rst_acc),
		.inspk(inspk),
		.outspk(int_spk),
		.activation(int_activation)
	);
	//instantiate the neuron
	lif #(
		.INTEGER_PRECISION(INTEGER_PRECISION),
		.DECIMAL_PRECISION(DECIMAL_PRECISION)
	) lif_dut(
		.rst(rst),
		.clk(spkclk),
		.vth(vth),
		.decay_rate(decay_rate),
		.grow_rate(grow_rate),
		.vrest(vrest),
		.reset_mechanism(reset_mechanism),
		.refractory_period(refractory_period),
		.inspk(int_spk),
		.activation(int_activation),
		.outspk(outspk),
		.vmem(vmem)
	);


endmodule
