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
`define SKY130A_SRAM
`include "vco_adc.v"
// `include "fifo.v"

`define REG_MPRJ_SLAVE       24'h300000 // VCO Based address
`define REG_MPRJ_VCO_CONFIG  8'h00
`define REG_MPRJ_FIFO_DATA   8'h04 // VCO read data from the fifo
`define REG_MPRJ_STATUS      8'h08 // VCO status
`define REG_MPRJ_NUM_DATA    8'h0C // VCO number of data writen into the fifo

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
    input [10:0] phase0_in,
    input [10:0] phase1_in,
    input [10:0] phase2_in,
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
    output [2:0] irq,
  // memory interface
  output mem_renb_o,
  output [9:0] mem_raddr_o,
  output mem_wenb_o,
  output [9:0] mem_waddr_o,
  output [31:0] mem_data_o,
  input [31:0] mem_data_i,
  input [31:0] mem_data2_i,
  output [3:0] wmask_o,
  output [2:0] vco_enb_o
);

   reg [9:0] oversample_reg;
   reg 	     ena_reg;
   reg 	     wbs_ack_reg;

   reg [9:0] wptr_reg;
   reg [9:0] rptr_reg;

   reg [1:0] 	 status_reg;
   reg [31:0] 	 num_data_reg;
   reg [31:0] 	 data_o;
   reg [31:0] 	 mem_rdata_reg;
   reg 		 full_reg;
   reg 		 empty_reg;
   reg 		 clear_wptr_reg;
   reg 		 clear_rptr_reg;
   reg 		 ren_1d_reg;
   reg [2:0] 	 vco_en_reg;

   wire [BITS-1:0] 	  adc_out;
   wire 		  adc_dvalid;
   wire 		  valid_w;
   wire 		  wen_w;
   wire [BITS-1:0] 	  fifo_out_w;
   // wire 		  empty_out_w;
   // wire 		  full_out_w;
   wire                   ren_w;
   wire 		  rst;
   wire 		  slave_sel;
   reg [10:0] 		  phase;

   assign rst = (~la_oenb[0]) ? la_data_in[0] : wb_rst_i;
   assign slave_sel = (wbs_adr_i[31:8] == `REG_MPRJ_SLAVE);
   
   assign valid_w = wbs_cyc_i & wbs_stb_i;
   assign wen_w   = wbs_we_i & (valid_w & wbs_sel_i[0]);
   assign ren_w   = ((wbs_we_i == 1'b0) & valid_w & ~wbs_ack_reg);   

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 status_reg <= 2'b0;
      end else begin
	 status_reg <= {full_reg, empty_reg};
     end
   end

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 num_data_reg <= {32{1'b0}};
      end else begin
	 if (adc_dvalid)
	   num_data_reg <= num_data_reg + 1;
      end
   end
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 wbs_ack_reg <= 1'b0;
      end else begin
	 wbs_ack_reg <= ((valid_w & (wbs_ack_o == 1'b0))
			 & (wbs_ack_reg == 1'b0));
      end
   end

   assign wbs_ack_o = (valid_w & (wbs_ack_reg == 1'b0)) ? wbs_we_i : wbs_ack_reg;
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 oversample_reg <= 10'b0;
	 ena_reg        <= 1'b0;
	 clear_wptr_reg <= 1'b0;
	 clear_rptr_reg <= 1'b0;
	 vco_en_reg <= 3'h0;
      end else begin
	 if (slave_sel && wen_w && wbs_adr_i[7:0] == 8'h00) begin
	    ena_reg <= wbs_dat_i[31];
	    clear_wptr_reg <= wbs_dat_i[30];
	    clear_rptr_reg <= wbs_dat_i[29];
	    vco_en_reg <= wbs_dat_i[28:26];
	    oversample_reg <= wbs_dat_i[9:0];
	 end
      end
   end

   always @* begin
      case (wbs_adr_i[7:0]) 
	`REG_MPRJ_VCO_CONFIG: data_o <= {ena_reg, clear_wptr_reg,
					 clear_rptr_reg, vco_en_reg,
					 16'h0, oversample_reg};
	`REG_MPRJ_FIFO_DATA: data_o <= fifo_out_w;
	`REG_MPRJ_STATUS: data_o <= status_reg;
	`REG_MPRJ_NUM_DATA: data_o <= num_data_reg;
	default: data_o <= 32'h0;
      endcase // case (wbs_adr_i[7:0])
      
   end
   always @* begin
      case (vco_en_reg)
	3'b001: phase <= phase0_in;
	3'b010: phase <= phase1_in;
	3'b100: phase <= phase2_in;
	default: phase <= phase0_in;
      endcase // case (vco_en_reg)
   end
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 wptr_reg <= 11'h0;
	 rptr_reg <= 11'h0;
	 full_reg <= 1'b0;
	 empty_reg <= 1'b1;
      end
      else begin
	 if (!full_reg && adc_dvalid) begin
	    wptr_reg <= rptr_reg + 11'h1;
	 end else if (clear_wptr_reg) begin
	    wptr_reg <= 10'h0;
	 end

	 if (wptr_reg == 10'h3FF) full_reg <= 1'b1;
	 else full_reg <= 1'b0;
	 if (wptr_reg == 10'h0) empty_reg <= 1'b1;
	 else empty_reg <= 1'b0;

	 if (!empty_reg && ren_w && wbs_adr_i[7:0] == 8'h4) begin
	    rptr_reg <= rptr_reg + 10'h1;
	 end else if (clear_rptr_reg) begin
	    rptr_reg <= 11'h0;
	 end
      end
   end
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1)
	ren_1d_reg <= 1'b0;
      else
	ren_1d_reg <= ren_w;
      if (empty_reg && adc_dvalid)
	mem_rdata_reg <= adc_out;
      else if (ren_1d_reg == 1'b1)
	mem_rdata_reg <= mem_data_i;
   end
   assign mem_waddr_o = wptr_reg;
   assign mem_raddr_o = rptr_reg;
   assign mem_renb_o = ~ren_w;
   assign mem_wenb_o = ~adc_dvalid;
   assign mem_data_o = adc_out;
   assign fifo_out_w = mem_rdata_reg;

   // IO
   assign io_out    = fifo_out_w;
   assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};
   assign irq  = 3'b000;
   assign wbs_dat_o = data_o;
   assign vco_enb_o = ~vco_en_reg;

   // fifo
   //   #(.DEPTH_WIDTH(11)
   //     ,.DATA_WIDTH(BITS))
   // sync_fifo
   //   (.clk(wb_clk_i)
   //    ,.rst(rst)
   //    ,.wr_en_i(adc_dvalid)
   //    ,.wr_data_i(adc_out)
   //    ,.full_o(full_out_w)
   //    ,.rd_en_i(ren_w)
   //    ,.empty_o(empty_out_w)
   //    ,.rd_data_o(fifo_out_w));
   
//    sky130_sram_8kbyte_1rw1r_32x2048_8
//      mem_0 (
// `ifdef USE_POWER_PINS
// 	    .vccd1(vccd1),
// 	    .vssd1(vccd1),
// `endif
// // Port 0: RW
// 	    .clk0(wb_clk_i),
// 	    .csb0(1'b0),
// 	    .web0(~adc_dvalid),
// 	    .wmask0(4'b1111),
// 	    .addr0(write_cnt_reg),
// 	    .din0(adc_out),
// 	    .dout0(),
// // Port 1: R
// 	    .clk1(wb_clk_i),
// 	    .csb1(1'b0),
// 	    .addr1(read_cnt_reg),
// 	    .dout1()
//   );

   vco_adc vco_adc_0
     (.clk(wb_clk_i)
      ,.rst(rst)
      ,.phase_in(phase)
      ,.oversample_in(oversample_reg)
      ,.enable_in(ena_reg)
      ,.data_out(adc_out)
      ,.data_valid_out(adc_dvalid)
      );

endmodule
`default_nettype wire
