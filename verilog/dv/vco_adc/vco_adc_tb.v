`default_nettype wire

`timescale 1 ns / 1 ps
`include "vco.v"
`include "vco_adc.v"
module vco_adc_tb;

   reg clk;
   reg rst;
   reg enable;
   integer data_counter, f;

   wire [10:0] phase_out;
   wire [10:0] sum_in;
   wire [3:0]  sum_out;
   wire [31:0] sinc_out;
   wire [31:0] sinc_out2;
   wire        valid_out;

   always #20 clk <= (clk === 1'b0);
   
   initial begin
      clk = 0;
      f = $fopen("adc_out.txt");
   end
   initial begin
      $dumpfile("vco_adc_tb.vcd");
      $dumpvars(0, vco_adc_tb);
      @(rst == 1'b0)
      $display("Monitor: Test VCO_ADC (RTL) Started!");
      repeat (4000) @(posedge clk);
      @(data_counter == 32'h800);
      $display("Monitor: Test VCO_ADC (RTL) Passed!");
      $finish;
   end

   initial begin
      rst <= 1'b1;
      #2000;
      rst <= 1'b0;
   end
   // // test enable signal
   // initial begin
   //    enable = 1'b0;
   //    @(rst == 1'b0);
   //    repeat (40) @(posedge clk);
   //    enable = 1'b1;
   //    repeat (20*256) @(posedge clk);
   //    enable = 1'b0;
   //    repeat (2000) @(posedge clk);
   //    enable = 1'b1;
   // end
   initial begin
      enable = 1'b0;
      @(rst == 1'b0);
      repeat (40) @(posedge clk);
      enable = 1'b1;
      @(posedge clk);
   end
   always @(valid_out) begin

   end

   always @(posedge clk) begin
      if (rst == 1'b1)
   	data_counter <= 0;
      else if (valid_out) begin
   	 data_counter <= data_counter + 1;
	 $display("Data: %08X", sinc_out);
	 $fwrite(f, "%d\n", sinc_out);
      end
   end
   vco #(.PHASE_WIDTH(11)) vco_0
     (.enb(1'b0),
      .p(phase_out));

   vco_adc vco_adc_0
     (.clk(clk),
      .rst(rst),
      .oversample_in(10'h1ff),
      .enable_in(enable),
      .phase_in(phase_out),
      .data_out(sinc_out),
      .data_valid_out(valid_out));
   
endmodule // vco_adc_tb
