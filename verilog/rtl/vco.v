// behavior model of the vco
module vco
  #(
    parameter PHASE_WIDTH = 11)
  (
   input 		    clk,
   input 		    rst,
//   input 		    enable_in,
   input 		    analog_in, 
   output [PHASE_WIDTH-1:0] data_o
   );

   reg [14:0] 		     counter_reg;
   reg [PHASE_WIDTH-1:0] 		     vco_val[0:9999];
   initial begin
      $display("Load vco-phase");
      $readmemb("testcase_f10khz_oversample_512_fs25Mhz.txt", vco_val);
   end

   always @(posedge clk) begin
      if (rst == 1'b1) begin
	 counter_reg <= 15'h0;
      end else begin
	 if (counter_reg == 9999)
	   counter_reg <= 15'h0;
	 else
	   counter_reg <= counter_reg + 1;
      end
   end

   assign data_o = vco_val[counter_reg];
endmodule // vco

