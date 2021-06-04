`default_nettype wire

`timescale 1 ns / 1 ps
`include "vco.v"
`include "vco_adc.v"
module vco_adc_tb;

   reg clk;
   reg rst;
   reg enable;

   wire [10:0] phase_out;
   wire [10:0] sum_in;
   wire [3:0]  sum_out;
   wire [31:0] sinc_out;
   wire [31:0] sinc_out2;
   wire        valid_out;

   always #20 clk <= (clk === 1'b0);
   
   initial begin
      clk = 0;
   end
   initial begin
      $dumpfile("vco_adc_tb.vcd");
      $dumpvars(0, vco_adc_tb);
      $display("Monitor: Test MPRJ (RTL) Started!");
      repeat (40000) @(posedge clk);
      $display("Monitor: Test MPRJ (RTL) Passed!");
      $finish;
   end

   initial begin
      rst <= 1'b1;
      #2000;
      rst <= 1'b0;
   end

   initial begin
      enable = 1'b0;
      @(rst == 1'b0);
      repeat (40) @(posedge clk);
      enable = 1'b1;
      repeat (20*256) @(posedge clk);
      enable = 1'b0;
      repeat (2000) @(posedge clk);
      enable = 1'b1;
   end

   vco #(.PHASE_WIDTH(11)) vco_0
     (.p(phase_out));

   // phase_readout
   //   #(.PHASE_WIDTH(11))
   // pr (.clk(clk),
   //     .rstn(rstn),
   //     .data_i(phase_out),
   //     .data_o(sum_in));

   // phase_sum
   //   #(.PHASE_WIDTH(11),
   //     .SUM_WIDTH(4))
   // ps (.clk(clk),
   //     .rstn(rstn),
   //     .phase_i(sum_in),
   //     .sum_o(sum_out));

   // sinc_ref #(.DATA_WIDTH(32))
   // sc (.clk(clk),
   //     .rstn(rstn),
   //     .data_in(sum_out),
   //     .data_out(sinc_out));

   // sinc_sync #(.DATA_WIDTH(32))
   // scs (.clk(clk),
   // 	.rstn(rstn),
   // 	.data_in(sum_out),
   // 	.oversample_in(10'hff),
   // 	.enable_in(enable),
   // 	.data_valid_out(valid_out),
   // 	.data_out(sinc_out2));
   vco_adc vco_adc_0
     (.clk(clk),
      .rst(rst),
      .oversample_in(10'hff),
      .enable_in(enable),
      .phase_in(phase_out),
      .data_out(sinc_out),
      .data_valid_out(valid_out));
   
endmodule // vco_adc_tb
