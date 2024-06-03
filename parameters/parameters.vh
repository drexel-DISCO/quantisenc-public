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
// File     	: parameters.vh
// Desc     	: This is the top-level parameter file that is to be generated using a Python script.
// -----------------------------------------------------------------------------*/
//hardware parameters
parameter INTEGER_PRECISION = 3,	//swctrl
parameter DECIMAL_PRECISION = 4,	//swctrl
parameter DATA_WIDTH = 32, 				//swctrl
parameter LAYER_ENC_BITS = 8,	//swctrl
parameter NEURON_ENC_BITS = 12,	//swctrl
parameter FANIN_ENC_BITS = 12,	//swctrl
localparam ADDR_WIDTH = (LAYER_ENC_BITS+NEURON_ENC_BITS+FANIN_ENC_BITS),
localparam LAYER_ADDR_START = (NEURON_ENC_BITS+FANIN_ENC_BITS),
localparam PRECISION = (1+INTEGER_PRECISION+DECIMAL_PRECISION),
//model parameters
//this configuration implements
//software: <input-layer><hidden-layer-1><hidden-layer-2><hidden-layer-3>...<output-layer>
//hardware: <hidden-layer-1><hidden-layer-2><hidden-layer-3>...<output-layer>
//important note: the input layer neurons are implemented in software/testbench
parameter INPUT_NEURONS = 256,	//swctrl
parameter HIDDEN_LAYERS = 1,	//swctrl
parameter HIDDEN_LAYER_NEURONS = 256,	//swctrl
parameter OUTPUT_NEURONS = 10,	//swctrl
localparam HARDWARE_LAYERS = (HIDDEN_LAYERS + 1),
localparam LAYER_WIDTH = $clog2(1+HARDWARE_LAYERS),
//gpout/configuration parameters
parameter CONFIG_REG = 8,
parameter GPOUT_WIDTH = 32,
//dummy parameter
localparam DUMMY_HW_PARAMETER = 0
