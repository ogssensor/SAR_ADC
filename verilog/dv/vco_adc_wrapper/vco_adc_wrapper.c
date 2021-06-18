/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

// --------------------------------------------------------
#define reg_mprj_vco_adc (*(volatile uint32_t*)0x30000004)
#define reg_mprj_status  (*(volatile uint32_t*)0x30000008)
#define reg_mprj_no_data (*(volatile uint32_t*)0x3000000C)

#define VCO_IDLE    0x0
#define VCO_WORKING 0x1
#define VCO_EMPTY   0x2
#define VCO_FULL    0x3

static uint32_t mprj_set_config(uint32_t enable, uint32_t ovs) {
  // enable sinc3
  uint32_t cfg = (enable << 31);
  cfg |= 1 << 26;
  cfg |= ovs & 0x3FF;
  // enable vco0

  return cfg;
}

static uint32_t read_data(uint32_t* data, int len) {
  for (int i = 0; i < len; ++i)
    data[i] = reg_mprj_vco_adc;
}
static uint32_t vco_data[32];

void main()
{
    // The upper GPIO pins are configured to be output
    // and accessble to the management SoC.
    // Used to flag the start/end of a test
    // The lower GPIO pins are configured to be output
    // and accessible to the user project.  They show
    // the project count value, although this test is
    // designed to read the project count through the
    // logic analyzer probes.
    // I/O 6 is configured for the UART Tx line

    reg_spimaster_config = 0xb002;      // Apply stream mode

#ifdef USE_PLL
    reg_spimaster_data = 0x80;          // Write 0x80 (write mode)
    reg_spimaster_data = 0x08;          // Write 0x18 (start address)
    reg_spimaster_data = 0x01;          // Write 0x01 to PLL enable, no DCO mode
    reg_spimaster_config = 0xa102;      // Release CSB (ends stream mode)

    reg_spimaster_config = 0xb002;      // Apply stream mode
    reg_spimaster_data = 0x80;          // Write 0x80 (write mode)
    reg_spimaster_data = 0x11;          // Write 0x11 (start address)
    reg_spimaster_data = 0x06;          // Write 0x03 to PLL output divider
    reg_spimaster_config = 0xa102;      // Release CSB (ends stream mode)

    reg_spimaster_config = 0xb002;      // Apply stream mode
    reg_spimaster_data = 0x80;          // Write 0x80 (write mode)
    reg_spimaster_data = 0x09;          // Write 0x09 (start address)
    reg_spimaster_data = 0x00;          // Write 0x00 to clock from PLL (no bypass)
    reg_spimaster_config = 0xa102;      // Release CSB (ends stream mode)

    reg_spimaster_config = 0xb002;      // Apply stream mode
    reg_spimaster_data = 0x80;          // Write 0x80 (write mode)
    reg_spimaster_data = 0x12;          // Write 0x12 (start address)
    reg_spimaster_data = 0x03;          // Write 0x03 to feedback divider (was 0x04)
    reg_spimaster_config = 0xa102;      // Release CSB (ends stream mode)
#endif

    reg_mprj_datal = 0x00000000;
    reg_mprj_datah = 0x00000000;

    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_9  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_8  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_7  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_5  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_4  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_3  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_2  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_1  = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_0  = GPIO_MODE_USER_STD_OUTPUT;

    reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;

    // Set UART clock to 64 kbaud (enable before I/O configuration)
    reg_uart_clkdiv = 625;
    reg_uart_enable = 1;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    /* TEST:  Recast channels 35 to 32 to allow input to user project	*/
    /* This is done locally only:  Do not run reg_mprj_xfer!		*/
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;

    // Configure LA probes [31:0], [127:64] as inputs to the cpu
    // Configure LA probes [63:32] as outputs from the cpu
    reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]
    /* reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32] */
    /* reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF;    // [95:64] */
    /* reg_la3_oenb = reg_la3_iena = 0xFFFFFFFF;    // [127:96] */

    // Flag start of the test
    reg_mprj_datal = 0xAB400000;

    // Set Counter value to zero through LA probes [63:32]
    // reg_la1_data = 0x00000000;

    // Configure LA probes from [63:32] as inputs to disable counter write
    // reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;

    // reg_mprj_datal = 0xAB410000;
    // reg_mprj_datah = 0x00000000;

    // Test ability to force data on channel 37
    // NOTE:  Only the low 6 bits of reg_mprj_datah are meaningful

  // Bit 31  : enable VCO
  // Bit 9:0 : OVS = 256
    reg_mprj_slave = mprj_set_config(1, 255);
    while(((reg_mprj_status >> 1) & 0x1) == 0);
    // read until empty
    for (int i = 0; i < 2048; ++i)
      vco_data[0] = reg_mprj_vco_adc;
    /*
    // reset wptr & rptr
    reg_mprj_slave = (1<< 30) | (1 << 29) | (1 << 26) | 255;
    // sample again
    reg_mprj_slave = mprj_set_config(1, 255);
    while(((reg_mprj_status >> 1) & 0x1) == 0);
    // read until empty
    for (int i = 0; i < 16; ++i)
      vco_data[0] = reg_mprj_vco_adc;
    */
    // Flag end of the test
    reg_mprj_datal = 0xAB900000;
}
