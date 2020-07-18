# icestick-uart

Simple UART sender and receiver for the lattice icestick. The default configuration can be found at `hdl/uart_top.vhd`. Every received word gets echoed back. The parameters are 115200/8-N-1 (<https://en.wikipedia.org/wiki/8-N-1>). However, sender and receiver can be used independently and the parameter can be modified.

## Repository structure

- hdl: Contains the hardware design.
- sim: Contains a few testbenches.
- syn: Contains the scripts and constraints for synthesis.

## Usage

- Clone the repository: `--recurse-submodules`
- Plug in your icestick
- Synthesize the design and upload the bitstream: `cd syn && ./synth.sh`
- Use putty or another serial terminal for communication:
  - Make sure your user is in the `dialout` group: `sudo usermod -a -G dialout ${USER}`
  - Start putty via: `putty /dev/ttyUSB1 -serial -sercfg 115200,8,n,1,N`
  - Type something. The received data from the icestick should be displayed in the terminal.

## Ressource usage

For the default configuration, the following resources are needed:

resource | absolute usage | relative usage
-------------|----------:|---:
ICESTORM_LC  | 109/ 1280 |  8%
ICESTORM_RAM |   0/   16 |  0%
SB_IO        |   4/  112 |  3%
SB_GB        |   1/    8 | 12%
ICESTORM_PLL |   0/    1 |  0%
SB_WARMBOOT  |   0/    1 |  0%
