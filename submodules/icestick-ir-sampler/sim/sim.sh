#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT"/../icestick-uart/hdl/uart_tx.vhd
ghdl -a "$ROOT"/hdl/*.vhd
ghdl -a ../tb_ir_sampler.vhd
ghdl -e uart_tx
ghdl -e ir_sampler
ghdl -e tb_ir_sampler
ghdl -r tb_ir_sampler --wave=waveform.ghw --stop-time=100ms
gtkwave waveform.ghw ../waveform.gtkw