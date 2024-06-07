# quantisenc  
A (quanti)zed (s)pike-(e)nabled (n)eural (c)ore design  
  
## Directory Structure  
src     : All verilog files of the design.  
tb      : A sample testbench to load synaptic weights and perform computations.  
xdc     : Constraints file for synthesizing the design.  
weight  : Contains synaptic weights and addresses to be programmed in the hardware.  
input   : Contains spike input to be driven to the hardware.  
output  : Contains spike and vmem output collected from the hardware.  

Detailed design specification and user guide is under development.
  
## Bug Reporting  
If you find any bug in the design, please email Ms. Shadi Matinizadeh (sm4884@drexel.edu).

## Citation Information  
If you find this code useful in your research, please cite our paper:  

S. Matinizadeh, A. Mohammadhassani, N. Pacik-Nelson, I. Polykretis, A. Mishra, J. Shackleford, N. Kandasamy, E. Gallo, and A. Das. "A Fully-Configurable Digital Spiking Neuromorphic Hardware Design with Variable Quantization and Mixed Precision." IEEE International Midwest Symposium on Circuits and Systems (MWSCAS), 2024.  

@inproceedings{quantisenc,  
title={A Fully-Configurable Digital Spiking Neuromorphic Hardware Design with Variable Quantization and Mixed Precision},  
author={Matinizadeh, S. and Mohammadhassani, A. and Pacik-Nelson, N. and  Polykretis, I. and Mishra, A. and Shackleford, J. and Kandasamy, N. and Gallo, E. and Das, A.},  
booktitle ={IEEE International Midwest Symposium on Circuits and Systems (MWSCAS)},  
year={2024},  
publisher={IEEE}  
}  
