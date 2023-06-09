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

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) vco_adc

set ::env(VERILOG_FILES) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/vco_adc.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) ""
set ::env(CLOCK_PERIOD) "10"
set ::env(SYNTH_STRATEGY) "DELAY 2"
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 270 270"
# set ::env(FP_SIZING) relative
# set ::env(FP_CORE_UTIL) 20
set ::env(DESIGN_IS_CORE) 0
# set ::env(GLB_RT_ADJUSTMENT) 0.21
# set ::env(GLB_RT_ALLOW_CONGESTION) 1

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.55
set ::env(PL_ROUTABILITY_DRIVEN) 0

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0
