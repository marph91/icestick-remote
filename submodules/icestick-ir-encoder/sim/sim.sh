#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT"/hdl/*.vhd
ghdl -a "$ROOT"/sim/tb_ir_encoder.vhd
ghdl -e ir_encoder
ghdl -e tb_ir_encoder
ghdl -r tb_ir_encoder --wave=waveform.ghw --stop-time=200ms
gtkwave waveform.ghw ../waveform.gtkw