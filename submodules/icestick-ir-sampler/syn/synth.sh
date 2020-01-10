#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT"/../icestick-uart/hdl/uart_tx.vhd
ghdl -a "$ROOT"/hdl/*.vhd
# ghdl --synth ir_sampler
yosys -m ghdl -p "ghdl ir_sampler; synth_ice40 -json ir_sampler.json"