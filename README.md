# icestick-remote

[![check_scripts](https://github.com/marph91/icestick-remote/workflows/check_scripts/badge.svg)](https://github.com/marph91/icestick-remote/actions?query=workflow%3Acheck_scripts)
[![synthesis](https://github.com/marph91/icestick-remote/workflows/hdl_synthesis/badge.svg)](https://github.com/marph91/icestick-remote/actions?query=workflow%3Ahdl_synthesis)

Remote control in VHDL, which fits on a Lattice icestick. The whole design flow was done using open source tools. It was tested with a Panasonic TX-49FXW654 and can be extended for other devices and protocols.

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

To process the VHDL code and finally flash the generated bitstream on the device, the open source toolchain was used. This includes [ghdl](https://github.com/ghdl/ghdl), [ghdl-yosys-plugin](https://github.com/ghdl/ghdl-yosys-plugin), [yosys](https://github.com/YosysHQ/yosys), [nextpnr](https://github.com/YosysHQ/nextpnr) and [icestorm](https://github.com/cliffordwolf/icestorm). Further information about the tools can be found at the linked pages.
There are also prepared docker container, including all the mentioned tools. For more information, see <https://github.com/ghdl/docker> respectively <https://github.com/hdl/containers>.

## Usage

- Create the bitstream and flash the icestick: `cd syn && ./synth.sh`
- Send control signals to the icestick, which get encoded and sent via the infrared LED: `cd gui && ./remote_gui.py`
- New codes can be obtained by pressing the "Start sampling" button at the "Sample" tab.

## Resource usage

resource | absolute usage | relative usage
-------------|----------:|---:
ICESTORM_LC  | 572/ 1280 | 44%
ICESTORM_RAM |   2/   16 | 12%
SB_IO        |   6/  112 |  5%
SB_GB        |   4/    8 | 50%
ICESTORM_PLL |   0/    1 |  0%
SB_WARMBOOT  |   0/    1 |  0%

## Further information

Panasonic remotes use the Kaseikyo protocol. Other Panasonic devices may use different codes, which can be extended. Since the Kaseikyo protocol uses pulse distance coding, other protocols with the same encoding technique could be added trivially. The NEC protocol is one of them and can be activated via generic. However, it wasn't tested.

Useful links:

- <https://www.vishay.com/docs/81288/tfdu4101.pdf>
- <https://www.mikrocontroller.net/articles/IRMP#KASEIKYO>
- <https://www.mikrocontroller.net/attachment/4246/IR-Protokolle_Diplomarbeit.pdf>
- <https://www.roboternetz.de/phpBB2/files/entwicklung_und_realisierung_einer_universalinfrarotfernbedienung_mit_timerfunktionen.pdf>
- <http://www.hifi-remote.com/wiki/index.php/Panasonic>
- <https://github.com/ukw100/IRMP/blob/master/src/irmpprotocols.h>
