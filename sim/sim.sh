#!/bin/sh

set -e

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a "$ROOT"/submodules/icestick-uart/hdl/uart_rx.vhd
ghdl -a "$ROOT"/submodules/icestick-uart/hdl/uart_tx.vhd
ghdl -e uart_rx
ghdl -e uart_tx
ghdl -a "$ROOT"/submodules/icestick-ir-encoder/hdl/*.vhd
ghdl -e ir_encoder
ghdl -a "$ROOT"/submodules/icestick-ir-sampler/hdl/*.vhd
ghdl -e bram
ghdl -e ir_sampler

ghdl -a "$ROOT"/hdl/*.vhd
ghdl -a "$ROOT"/sim/tb_remote.vhd
ghdl -e remote
ghdl -e tb_remote
ghdl -r tb_remote --wave=waveform.ghw --stop-time=200ms
gtkwave waveform.ghw ../waveform.gtkw
