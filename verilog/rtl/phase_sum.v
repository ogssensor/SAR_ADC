module phase_sum
  #(
    parameter PHASE_WIDTH = 11,
    parameter SUM_WIDTH = 4) // ceil(log2(BIT_WIDTH))
   (
    input 		     clk,
    input 		     rst,
    input [PHASE_WIDTH-1:0] phase_i,
    output [SUM_WIDTH-1:0]  sum_o 
    );

   reg [SUM_WIDTH-1:0]      sum;
   integer 		    idx;

   always @* begin
      sum = {SUM_WIDTH{1'b0}};
      for (idx = 0; idx < PHASE_WIDTH; idx = idx + 1) begin
	 sum = sum + phase_i[idx];
      end
   end

   assign sum_o = sum;
   
endmodule // phase_sum
