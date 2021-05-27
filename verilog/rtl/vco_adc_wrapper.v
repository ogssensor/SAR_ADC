// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */
`include "vco_adc.v"
`include "fifo.v"

`define REG_MPRJ_SLAVE       32'h30000000 // VCO enable
`define REG_MPRJ_VCO_ADC     32'h30000004 // VCO result
`define REG_MPRJ_STATUS      32'h30000008 // VCO status
`define REG_MPRJ_NO_DATA     32'h3000000C // VCO #data
`define REG_MPRJ_IRQ         32'h30000010 // VCO interrupt

module vco_adc_wrapper #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
    input [10:0] phase_in,
    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

   reg [9:0] oversample_reg;
   reg 	     ena_reg;  
   reg 	     wbs_ack_reg;
   
   reg [1:0] 	 status_reg;
   reg [31:0] 	 no_data_reg;

   wire [BITS-1:0] 	  adc_out;
   wire 		  adc_dvalid;
   wire 		  valid_w;
   wire 		  wen_w;
   wire [BITS-1:0] 	  fifo_out_w;
   wire 		  empty_out_w;
   wire 		  full_out_w;
   wire                   ren_w;
   wire 		  rst;

   assign rst = (~la_oenb[0]) ? la_data_in[0] : wb_rst_i;
   
   assign valid_w = wbs_cyc_i & wbs_stb_i;
   assign wen_w   = wbs_we_i & (valid_w & wbs_sel_i[0]);
   assign ren_w   = ((wbs_we_i == 1'b0) & valid_w & ~wbs_ack_reg);   

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 status_reg <= 2'b0;
      end else begin
	 if (ena_reg) begin
	    if (full_out_w)
	      status_reg <= 2'b11;   // FULL STATUS
	    else if (empty_out_w)
	      status_reg <= 2'b10;   // EMPTY STATUS
	    else
	      status_reg <= 2'b01;   // WORKING STATUS
	 end else
	   status_reg <= 2'b0;       // IDLE STATUS
      end
   end

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 no_data_reg <= {32{1'b0}};
      end else begin
	 if (adc_dvalid)
	   no_data_reg <= no_data_reg + 1;
      end
   end
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 wbs_ack_reg <= 1'b0;
      end else begin
	 wbs_ack_reg <= ((valid_w & (wbs_ack_o == 1'b0)) & (wbs_ack_reg == 1'b0));
      end
   end

   assign wbs_ack_o = (valid_w & (wbs_ack_reg == 1'b0)) ? wbs_we_i : wbs_ack_reg;
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 oversample_reg <= 10'b0;
	 ena_reg        <= 1'b0;
      end else begin
	 if (wen_w) begin
	    case (wbs_adr_i)
	      `REG_MPRJ_SLAVE : begin
		 ena_reg <= wbs_dat_i[31];
		 oversample_reg <= wbs_dat_i[9:0];
	        end
	      default begin
		 ena_reg <= ena_reg;
		 oversample_reg <= oversample_reg;
	      end
	    endcase
	 end
      end
   end

   assign wbs_dat_o = (wbs_adr_i == `REG_MPRJ_VCO_ADC) ? fifo_out_w  :
		      (wbs_adr_i == `REG_MPRJ_STATUS)  ? status_reg  :
		      (wbs_adr_i == `REG_MPRJ_NO_DATA) ? no_data_reg :
		      {BITS{1'b0}};
   
   // IO
   assign io_out    = fifo_out_w;
   assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};
   assign irq  = 3'b000;


   fifo
     #(.DEPTH_WIDTH(4)
       ,.DATA_WIDTH(BITS))
   sync_fifo
     (.clk(wb_clk_i)
      ,.rst(rst)
      ,.wr_en_i(adc_dvalid)
      ,.wr_data_i(adc_out)
      ,.full_o(full_out_w)
      ,.rd_en_i(ren_w)
      ,.empty_o(empty_out_w)
      ,.rd_data_o(fifo_out_w));

   vco_adc vco_adc_0
     (.clk(wb_clk_i)
      ,.rst(rst)
      ,.phase_in(phase_in)
      ,.oversample_in(oversample_reg)
      ,.enable_in(ena_reg)
      ,.data_out(adc_out)
      ,.data_valid_out(adc_dvalid)
      );

endmodule
`default_nettype wire
