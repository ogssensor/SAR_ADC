#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

## Caravel Pointers
CARAVEL_ROOT ?= ../../../caravel
CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_FIRMWARE_PATH = $(CARAVEL_PATH)/verilog/dv/caravel
CARAVEL_VERILOG_PATH  = $(CARAVEL_PATH)/verilog
CARAVEL_RTL_PATH = $(CARAVEL_VERILOG_PATH)/rtl
CARAVEL_BEHAVIOURAL_MODELS = $(CARAVEL_VERILOG_PATH)/dv/caravel

## User Project Pointers
UPRJ_VERILOG_PATH ?= ../../../verilog
UPRJ_RTL_PATH = $(UPRJ_VERILOG_PATH)/rtl
UPRJ_BEHAVIOURAL_MODELS = ../


## Simulation mode: RTL/GL
SIM?=RTL

.SUFFIXES:

PATTERN = vco_adc

all:  ${PATTERN:=.vcd}

%.vvp: %_tb.v 
ifeq ($(SIM),RTL)
	iverilog -DFUNCTIONAL -DSIM -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) \
	$< -o $@
else
	iverilog -DFUNCTIONAL -DSIM -DGL -I $(PDK_PATH) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) -I $(CARAVEL_VERILOG_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS) -I$(UPRJ_RTL_PATH)   -I $(UPRJ_VERILOG_PATH) \
	$< -o $@
endif

%.vcd: %.vvp
	vvp $<

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log

.PHONY: clean all
