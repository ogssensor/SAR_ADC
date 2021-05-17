//                              -*- Mode: Verilog -*-
// Filename        : vco_adc.v
// Description     : VCO-Based ADC
// Author          : Duy-Hieu Bui <hieubd@vnu.edu.vn>
// Created On      : Sat May 15 00:37:39 2021
// Last Modified By: 
// Last Modified On: Sat May 15 00:37:39 2021
// Update Count    : 0
// Status          : done
`include "vco.v"
`include "phase_readout.v"
`include "phase_sum.v"
`include "sinc_sync.v"

module vco_adc
  (
   input 	 clk,
   input 	 rst,
   input 	 analog_in,
   input [9:0] 	 oversample_in,
   input 	 enable_in,
   output [31:0] data_out,
   output 	 data_valid_out);

   wire [10:0] 	 phase_out;
   wire [10:0] 	 sum_in;
   wire [3:0] 	 sum_out;

   vco #(.PHASE_WIDTH(11)) dut 
     (.clk(clk),
      .rst(rst),
      // .enable_in(1'b1),
      .analog_in(analog_in),
      .data_o(phase_out));

   phase_readout
     #(.PHASE_WIDTH(11))
   pr (.clk(clk),
       .rst(rst),
       .data_i(phase_out),
       .data_o(sum_in));

   phase_sum
     #(.PHASE_WIDTH(11),
       .SUM_WIDTH(4))
   ps (.clk(clk),
       .rst(rst),
       .phase_i(sum_in),
       .sum_o(sum_out));

   sinc_sync #(.DATA_WIDTH(32))
   scs (.clk(clk),
	.rst(rst),
	.data_in(sum_out),
	.enable_in(enable_in),
	.oversample_in(oversample_in),
	.data_valid_out(data_valid_out),
	.data_out(data_out));

endmodule // vco_adc
