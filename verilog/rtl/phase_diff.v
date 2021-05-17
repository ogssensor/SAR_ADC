module phase_diff
   (
    input  clk,
    input  rst,
    input  data_i,
    output data_o
    );
   reg 	   ff_reg_0;
   reg 	   ff_reg_1;
   
   always @(posedge clk) begin
      if (rst == 1'b1) begin
	 ff_reg_0 <= 1'b0;
	 ff_reg_1 <= 1'b1;
      end else begin
	 ff_reg_0 <= data_i;
	 ff_reg_1 <= ff_reg_0;
      end
   end

   assign data_o = ff_reg_0 ~^ ff_reg_1;
endmodule // phase_diff

