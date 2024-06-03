#variables
set BUFR 7
set FANIN 256
#max neurons per layer
set MAX_NEURONS [expr $FANIN + $BUFR]
#set spike frequency in MHz
set SPK_FREQ 		1
#spike clock period is in ns
set SPKCLK_PERIOD 	[expr 1000 / $SPK_FREQ];
#mem clock period is in ns
set MEMCLK_PERIOD 	[expr $SPKCLK_PERIOD / $MAX_NEURONS]; 

#clock uncertainty
set CLK_UNCERTAINTY 0.1
set MEMCLK_UNCERTAINTY 0.1

#input/output delay
set INPUT_DELAY_SPKCLK	[expr $SPKCLK_PERIOD * 0.2]
set OUTPUT_DELAY_SPKCLK	[expr $SPKCLK_PERIOD * 0.2]

set INPUT_DELAY_MEMCLK	[expr $MEMCLK_PERIOD * 0.2]
set OUTPUT_DELAY_MEMCLK	[expr $MEMCLK_PERIOD * 0.2]

#clock constraints
create_clock 		-period $SPKCLK_PERIOD 		-name spkclk 	[get_ports  spkclk]
set_clock_uncertainty 	-setup $CLK_UNCERTAINTY 			[get_clocks spkclk]
set_clock_uncertainty 	-hold $CLK_UNCERTAINTY 				[get_clocks spkclk]

create_clock 		-period $MEMCLK_PERIOD 		-name memclk 	[get_ports  memclk]
set_clock_uncertainty 	-setup $MEMCLK_UNCERTAINTY 			[get_clocks memclk]
set_clock_uncertainty 	-hold $MEMCLK_UNCERTAINTY 			[get_clocks memclk]

#reset constraints
set_false_path -from [get_ports rst]
set_false_path -from [get_clocks spkclk] -to [get_clocks memclk]
set_false_path -from [get_clocks memclk] -to [get_clocks spkclk]

#set input delays

set_input_delay -clock memclk -rise -max $INPUT_DELAY_MEMCLK [get_ports mem_write*]
set_input_delay -clock memclk -fall -max $INPUT_DELAY_MEMCLK [get_ports mem_write*]

set_input_delay -clock memclk -rise -max $INPUT_DELAY_MEMCLK [get_ports cfg_write*]
set_input_delay -clock memclk -fall -max $INPUT_DELAY_MEMCLK [get_ports cfg_write*]

set_input_delay -clock memclk -rise -max $INPUT_DELAY_MEMCLK [get_ports wr_*]
set_input_delay -clock memclk -fall -max $INPUT_DELAY_MEMCLK [get_ports wr_*]

set_input_delay -clock spkclk -rise -max $INPUT_DELAY_SPKCLK [get_ports spk_in*]
set_input_delay -clock spkclk -fall -max $INPUT_DELAY_SPKCLK [get_ports spk_in*]

set_output_delay -clock spkclk -rise -max $OUTPUT_DELAY_SPKCLK [all_outputs]
set_output_delay -clock spkclk -fall -max $OUTPUT_DELAY_SPKCLK [all_outputs]

#set IOSTANDARDS
set_property IOSTANDARD LVCMOS12 [get_ports spkclk]
set_property IOSTANDARD LVCMOS12 [get_ports memclk]
set_property IOSTANDARD LVCMOS12 [get_ports rst]
set_property IOSTANDARD LVCMOS12 [all_outputs]

#static & dynamic power constraints
set_operating_conditions -process maximum
set_operating_conditions -design_power_budget 2.0
