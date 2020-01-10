#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT/submodules/icestick-uart/hdl/uart_rx.vhd"
ghdl -a "$ROOT/submodules/icestick-uart/hdl/uart_tx.vhd"
ghdl -a "$ROOT/submodules/icestick-ir-encoder/hdl/codec_pkg.vhd"
ghdl -a "$ROOT/submodules/icestick-ir-encoder/hdl/ir_encoder.vhd"
ghdl -a "$ROOT/submodules/icestick-ir-sampler/hdl/bram.vhd"
ghdl -a "$ROOT/submodules/icestick-ir-sampler/hdl/ir_sampler.vhd"
ghdl -a "$ROOT/hdl/remote.vhd"
# ghdl --synth remote
yosys -m ghdl -p 'ghdl remote; synth_ice40 -json remote.json'
nextpnr-ice40 --hx1k --json remote.json --pcf ../constraints/remote.pcf --asc remote.asc
icepack remote.asc remote.bin
iceprog remote.bin