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
set script_dir [file dirname [file normalize [info script]]]

source $script_dir/../../caravel/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg
set SRAM_MODEL_NAME "sky130_sram_4kbyte_1rw1r_32x1024_8"
### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/vco_adc_wrapper.v \
        $script_dir/../../verilog/rtl/${SRAM_MODEL_NAME}.v \
        $script_dir/../../verilog/rtl/vco_r100.v \
        $script_dir/../../verilog/rtl/vco.v"

# set ::env(EXTRA_LEFS) "\
# 	$script_dir/../../lef/vco_adc_wrapper.lef \
#         $script_dir/../../lef/sky130_sram_8kbyte_1rw1r_32x2048_8.lef \
#         $script_dir/../../lef/vco.lef"
set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/vco_adc_wrapper.lef \
        $script_dir/../../lef/${SRAM_MODEL_NAME}.lef \
        $script_dir/../../lef/vco_r100.lef \
        $script_dir/../../lef/vco.lef"

set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/vco_adc_wrapper.gds \
        $script_dir/../../gds/${SRAM_MODEL_NAME}.gds \
        $script_dir/../../gds/vco_r100.gds \
        $script_dir/../../gds/vco.gds"

set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_PDN_CHECK_NODES) 0

# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0
## temporary disable klayout XOR check because of a large number of viols
set ::env(RUN_KLAYOUT_XOR) 0
## This needs a patch to openlane
set ::env(USE_SRAM_ABSTRACT) 1
## this needs a pdk build with the sram macros
set ::env(SRAM_ABSTRACT_MODEL) ${SRAM_MODEL_NAME}.mag
