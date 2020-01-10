#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT"/hdl/codec_pkg.vhd
ghdl -a "$ROOT"/hdl/ir_encoder.vhd
# ghdl --synth ir_encoder
yosys -m ghdl -p 'ghdl ir_encoder; synth_ice40 -json ir_encoder.json'