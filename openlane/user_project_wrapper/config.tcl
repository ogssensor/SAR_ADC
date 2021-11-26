# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_MACRO_HOOKS) "vco_adc_wrapper_1 vccd1 vssd1, vco_0 vccd2 vssd2, vco_1 vccd2 vssd2, vco_2 vccd2 vssd2"
set ::env(FP_PDN_ENABLE_MACROS_GRID) 1
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg
set SRAM_MODEL_NAME "sky130_sram_2kbyte_1rw1r_32x512_8"

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
        $::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/verilog/${SRAM_MODEL_NAME}.v \
	$script_dir/../../verilog/rtl/vco_adc_wrapper.v \
        $script_dir/../../verilog/rtl/vco_adc.v \
        $script_dir/../../verilog/rtl/vco_r100.v \
        $script_dir/../../verilog/rtl/vco_w6_r100.v \
        $script_dir/../../verilog/rtl/vco.v"


# set ::env(EXTRA_LEFS) "\
# 	$script_dir/../../lef/vco_adc_wrapper.lef \
#         $script_dir/../../lef/sky130_sram_8kbyte_1rw1r_32x2048_8.lef \
#         $script_dir/../../lef/vco.lef"
set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/vco_adc_wrapper.lef \
        $::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/lef/${SRAM_MODEL_NAME}.lef \
        $script_dir/../../lef/vco_adc.lef \
        $script_dir/../../lef/vco_r100.lef \
        $script_dir/../../lef/vco_w6_r100.lef \
        $script_dir/../../lef/vco.lef"
#        $script_dir/../../lef/vco.lef"
#        $script_dir/../../lef/vco_r100.lef


set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/vco_adc_wrapper.gds \
        $::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/gds/${SRAM_MODEL_NAME}.gds \
        $script_dir/../../gds/vco_adc.gds \
        $script_dir/../../gds/vco_r100.gds \
        $script_dir/../../gds/vco_w6_r100.gds \
        $script_dir/../../gds/vco.gds"
#        $script_dir/../../gds/vco.gds"
#        $script_dir/../../gds/vco_w6_r100.gds

set ::env(GLB_RT_MAXLAYER) 5

# disable pdn check nodes becuase it hangs with multiple power domains.
# any issue with pdn connections will be flagged with LVS so it is not a critical check.
set ::env(FP_PDN_CHECK_NODES) 0

set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(FP_PDN_ENABLE_RAILS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

## disable klayout xor
set ::env(RUN_KLAYOUT_XOR) 0
## This needs a patch to openlane
set ::env(USE_SRAM_ABSTRACT) 1
## this needs a pdk build with the sram macros
set ::env(SRAM_ABSTRACT_MODEL) $::env(PDK_ROOT)/sky130A/libs.ref/sky130_sram_macros/maglef/${SRAM_MODEL_NAME}.mag
set ::env(MAGIC_DRC_USE_GDS) 1
set ::env(GLB_RT_OBS) "met3 100 1612 783 2028.5, \
    		       met3 100 1020 783.1 1436.5, \
		       met3 900 1612 1583 2028.5, \
		       met3 900 1020 1583 1426.5, \
		       met1 100.340 1304.000 100.405 1304.140"
