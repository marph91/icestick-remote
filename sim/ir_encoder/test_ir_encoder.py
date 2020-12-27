import os
import pathlib

import cocotb
from cocotb.clock import Clock
from cocotb.monitors import Monitor
from cocotb.triggers import RisingEdge, Timer
from cocotb_test.simulator import run


# https://stackoverflow.com/questions/44624407/how-to-reduce-log-line-size-in-cocotb
os.environ["COCOTB_REDUCED_LOG_FMT"] = "1"
os.environ["SIM"] = "ghdl"


# Source: https://github.com/cocotb/cocotb/blob/aa956f83e119e4ca4615c5b8660eb15c4dfa8623/examples/dff/tests/dff_cocotb.py
class BitMonitor(Monitor):
    """Observe a single-bit input or output of the DUT."""

    def __init__(self, name, signal, clk, callback=None, event=None):
        self.name = name
        self.signal = signal
        self.clk = clk
        self.clkedge = RisingEdge(clk)
        self.output = []
        Monitor.__init__(self, callback, event)

    async def _monitor_recv(self):
        while True:
            # Capture signal at rising edge of clock
            await self.clkedge
            vec = self.signal.value
            self._recv(vec)
            self.output.append(vec)


@cocotb.test()
async def run_test(dut):
    # Clock is generated in the wrapper.
    # TODO: use clock_period from dut wrapper
    clock_period = 83.333  # ns

    output_mon = BitMonitor(name="output", signal=dut.osl_ir, clk=dut.sl_clk)

    dut.isl_valid <= 1
    dut.islv_data <= 0
    await Timer(6 * clock_period, units="ns")
    dut.isl_valid <= 0
    await Timer(200, units="ms")

    print(output_mon.output)


def get_files(path, pattern):
    return [p.resolve() for p in list(path.glob(pattern))]


def test_ir_encoder():
    record_waveform = True
    generics = {}
    run(
        vhdl_sources=(
            get_files(pathlib.Path(__file__).parent.absolute() / ".." / ".." / "submodules" / "icestick-ir-encoder" / "hdl", "*.vhd")
            + [pathlib.Path(__file__).parent.absolute() / ".." / ".." / "sim" / "ir_encoder" / "ir_encoder_wrapper.vhd"]
        ),
        toplevel="ir_encoder_wrapper",
        module="test_ir_encoder",
        # compile_args=["--work=ir_encoder"],
        parameters=generics,
        sim_args=["--wave=ir_encoder.ghw"] if record_waveform else None,
    )
