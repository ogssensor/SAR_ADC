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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
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

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);
   wire [10:0] 	 phase0, phase1, phase2;
   wire [31:0] 	 m2w_data;
   wire [31:0] 	 w2m_data;
   wire [9:0] 	 raddr;
   wire [9:0] 	 waddr;
   wire [3:0] 	 wmask;
   wire 	 renb;
   wire 	 wenb;
   wire [2:0] 	 vco_enb;
   wire [31:0] 	 m2w_data2;
/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

   vco_adc_wrapper
     vco_adc_1 (
`ifdef USE_POWER_PINS
	   .vdda1(vdda1),	// User area 1 3.3V power
	   .vdda2(vdda2),	// User area 2 3.3V power
	   .vssa1(vssa1),	// User area 1 analog ground
	   .vssa2(vssa2),	// User area 2 analog ground
	   .vccd1(vccd1),	// User area 1 1.8V power
	   .vccd2(vccd2),	// User area 2 1.8V power
	   .vssd1(vssd1),	// User area 1 digital ground
	   .vssd2(vssd2),	// User area 2 digital ground
`endif

	   .wb_clk_i(wb_clk_i),
	   .wb_rst_i(wb_rst_i),

	   // MGMT SoC Wishbone Slave

	   .wbs_cyc_i(wbs_cyc_i),
	   .wbs_stb_i(wbs_stb_i),
	   .wbs_we_i(wbs_we_i),
	   .wbs_sel_i(wbs_sel_i),
	   .wbs_adr_i(wbs_adr_i),
	   .wbs_dat_i(wbs_dat_i),
	   .wbs_ack_o(wbs_ack_o),
	   .wbs_dat_o(wbs_dat_o),

	   // Logic Analyzer

	   .la_data_in(la_data_in),
	   .la_data_out(la_data_out),
	   .la_oenb (la_oenb),

	   // IO Pads

	   .io_in (io_in),
	   .io_out(io_out),
	   .io_oeb(io_oeb),
	   // phase from vco
	   .phase0_in(phase0),
	   .phase1_in(phase1),
	   .phase2_in(phase2),
	   // IRQ
	   .irq(user_irq),
           .mem_renb_o(renb),
           .mem_raddr_o(raddr),
           .mem_wenb_o(wenb),
           .mem_waddr_o(waddr),
           .mem_data_o(w2m_data),
           .mem_data_i(m2w_data),
           .mem_data2_i(m2w_data2),
           .wmask_o(wmask),
           .vco_enb_o(vco_enb)
	   );

//    sky130_sram_8kbyte_1rw1r_32x2048_8
//      mem_0 (
// `ifdef USE_POWER_PINS
// 	    .vccd1(vccd1),
// 	    .vssd1(vssd1),
// `endif
// // Port 0: RW
// 	    .clk0(wb_clk_i),
// 	    .csb0(wenb),
// 	    .web0(wenb),
// 	    .wmask0(wmask),
// 	    .addr0(waddr),
// 	    .din0(w2m_data),
// 	    .dout0(m2w_data2),
// // Port 1: R
// 	    .clk1(wb_clk_i),
// 	    .csb1(renb),
// 	    .addr1(raddr),
// 	    .dout1(m2w_data)
//   );
   sky130_sram_4kbyte_1rw1r_32x1024_8
     mem_0 (
`ifdef USE_POWER_PINS
	    .vccd1(vccd1),
	    .vssd1(vssd1),
`endif
// Port 0: RW
	    .clk0(wb_clk_i),
	    .csb0(wenb),
	    .web0(wenb),
	    .wmask0(wmask),
	    .addr0(waddr),
	    .din0(w2m_data),
	    .dout0(m2w_data2),
// Port 1: R
	    .clk1(wb_clk_i),
	    .csb1(renb),
	    .addr1(raddr),
	    .dout1(m2w_data)
  );
   vco vco_0 (// .clk(wb_clk_i),
	  // .rst(wb_rst_i),
	  // .enable_in(1'b1),
`ifdef USE_POWER_PINS
	      .vccd2(vccd2),
	      .vssd2(vssd2),
`endif
	      .enb(vco_enb[0]),
	      .input_analog(analog_io[1]),
	      .p(phase0));
   assign analog_io[2] = phase0[9];
   vco vco_1 (// .clk(wb_clk_i),
	  // .rst(wb_rst_i),
	  // .enable_in(1'b1),
`ifdef USE_POWER_PINS
	      .vccd2(vccd2),
	      .vssd2(vssd2),
`endif
	      .enb(vco_enb[1]),
	      .input_analog(analog_io[3]),
	      .p(phase1));
   assign analog_io[4] = phase1[9];
   vco vco_2 (// .clk(wb_clk_i),
	  // .rst(wb_rst_i),
	  // .enable_in(1'b1),
`ifdef USE_POWER_PINS
	      .vccd2(vccd2),
	      .vssd2(vssd2),
`endif
	      .enb(vco_enb[2]),
	      .input_analog(analog_io[5]),
	      .p(phase2));
   assign analog_io[6] = phase2[9];

endmodule	// user_project_wrapper

`default_nettype wire
