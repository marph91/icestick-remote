# icestick-remote

![](https://github.com/marph91/github-actions-playground/workflows/check_scripts/badge.svg)
![](https://github.com/marph91/github-actions-playground/workflows/hdl_synthesis/badge.svg)

Remote control in VHDL, which fits on a Lattice icestick. The whole design flow was done using open source tools. It was tested with a Panasonic TX-49FXW654 and can be extended for other devices.

## Repository structure
- gui: Contains a python script to provide control signals to the FPGA.
- hdl: Contains the toplevel hardware design.
- sim: Contains scripts for a few manual tests.
- submodules: Contains the following three submodules:
  - icestick-ir-encoder: Used to encode a signal to the infrared protocol.
  - icestick-ir-sampler: Used to sample new codes from a remote control.
  - icestick-uart: Used to communicate with the icestick.
- syn: Contains the scripts and constraints for synthesis and following steps.

## Prerequisites
- ghdl: https://github.com/ghdl/ghdl
- ghdlsynth: https://github.com/tgingold/ghdlsynth-beta
- yosys: https://github.com/YosysHQ/yosys
- nextpnr: https://github.com/YosysHQ/nextpnr
- icestorm: https://github.com/cliffordwolf/icestorm

## Usage
- Create the bitstream and flash the icestick: `cd syn && ./synth.sh`
- Send control signals to the icestick, which get encoded and sent via the infrared LED: `cd gui && ./remote_gui.py`
- New codes can be obtained by pressing the "Start sampling" button at the "Sample" tab.

## Further information
Panasonic remotes use the Kaseikyo protocol. Other Panasonic devices may use different codes, which can be extended. The NEC protocol can be also activated via generic. However, it wasn't tested.

Useful links:
- https://www.vishay.com/docs/81288/tfdu4101.pdf
- https://www.mikrocontroller.net/articles/IRMP#KASEIKYO
- https://www.mikrocontroller.net/attachment/4246/IR-Protokolle_Diplomarbeit.pdf
- https://www.roboternetz.de/phpBB2/files/entwicklung_und_realisierung_einer_universalinfrarotfernbedienung_mit_timerfunktionen.pdf
- http://www.hifi-remote.com/wiki/index.php/Panasonic
