DEVICE  := hx1k
PACKAGE := tq144
CONSTRAINTS_FILE := constraints/remote.pcf

GHDL          ?= ghdl
GHDL_SYNTH    ?= ghdl
YOSYS_PLUGIN  ?= -m ghdl
YOSYS         ?= yosys
YOSYS_SYNTH   ?= synth_ice40
NEXTPNR       ?= nextpnr-ice40
ICEPACK       ?= icepack

ifeq ($(USE_CONTAINERS),1)
include ../docker.mk
endif

GHDL_FLAGS    += --std=08
YOSYS_FLAGS   += -q
NEXTPNR_FLAGS += -q

SYN_FILES = \
	../submodules/icestick-uart/hdl/uart_rx.vhd \
	../submodules/icestick-uart/hdl/uart_tx.vhd \
	../hdl/ir_encoder/codec_pkg.vhd \
	../hdl/ir_encoder/ir_encoder.vhd \
	../hdl/ir_sampler/bram.vhd \
	../hdl/ir_sampler/ir_sampler.vhd \
	../hdl/remote.vhd

all: remote.bin
	@true

.DEFAULT: all

remote.json: $(SYN_FILES)
	$(YOSYS) $(YOSYS_FLAGS) $(YOSYS_PLUGIN) \
		-p \
		"$(GHDL_SYNTH) $(GHDL_FLAGS) $(SYN_FILES) -e remote; \
		$(YOSYS_SYNTH) \
		-json $@" 2>&1 | tee yosys-report.txt

remote.asc: remote.json
	$(NEXTPNR) \
		$(NEXTPNR_FLAGS) \
		--$(DEVICE) --package "$(PACKAGE)" \
		--pcf $(CONSTRAINTS_FILE) \
		--json $< \
		--asc $@

remote.bin: remote.asc
	$(ICEPACK) $< $@

load: remote.bin
	iceprog $<

.PHONY: load

clean:
	rm -fr *.cf *.json *-report.txt *.asc *.bin abc.history

.PHONY: clean
