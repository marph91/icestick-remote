#!/bin/sh

set -e

# parse arguments
flash=false
while test $# -gt 0; do
  case "$1" in
    --flash)
        flash=true
        break
        ;;
    *)
        break
        ;;
    esac
done

ROOT="$(pwd)/.."

rm -rf build
mkdir -p build
cd build

ghdl -a --std=08 "$ROOT/submodules/icestick-uart/hdl/uart_rx.vhd"
ghdl -a --std=08 "$ROOT/submodules/icestick-uart/hdl/uart_tx.vhd"
ghdl -a --std=08 "$ROOT/submodules/icestick-ir-encoder/hdl/codec_pkg.vhd"
ghdl -a --std=08 "$ROOT/submodules/icestick-ir-encoder/hdl/ir_encoder.vhd"
ghdl -a --std=08 "$ROOT/submodules/icestick-ir-sampler/hdl/bram.vhd"
ghdl -a --std=08 "$ROOT/submodules/icestick-ir-sampler/hdl/ir_sampler.vhd"
ghdl -a --std=08 "$ROOT/hdl/remote.vhd"
yosys -m ghdl -p 'ghdl --std=08 remote; synth_ice40 -json remote.json'
nextpnr-ice40 --hx1k --package tq144 --json remote.json --pcf ../constraints/remote.pcf --asc remote.asc
icepack remote.asc remote.bin

if [ "$flash" = true ]; then
    iceprog remote.bin
fi