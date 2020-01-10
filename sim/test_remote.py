#!/usr/bin/env python3

"""Testing functions for the remote control."""

import serial
import serial.tools.list_ports

import matplotlib.pyplot as plt
plt.switch_backend("TkAgg")


def negate(str_in: str) -> str:
    """Bitwise negate a string of bits."""
    # TODO: Remove duplicated function definition.
    # TODO: figure out why negation is needed. uart and ir rx are low active.
    assert all(character in ["0", "1"] for character in str_in)
    str_in.replace("1", "X").replace("0", "1").replace("X", "0")
    return str_in.replace("1", "X").replace("0", "1").replace("X", "0")


def test_uart():
    """Test whether an UART transmission on the serial port works."""
    available_ports = list(serial.tools.list_ports.grep("0403:6010"))
    print("%d serial ports found." % len(available_ports))

    for port in available_ports:
        print("port", port.device)
        with serial.Serial(port.device, baudrate=115200, timeout=1) as ser:
            # TODO: why the values have to be inverted?
            #       bit order has to be inverted to process the values easier
            #       in vhdl
            # VOL UP
            # words_send = ["01000000",
            #               "00000100",
            #               "00000001",
            #               "00000000",
            #               "00000100",
            #               "00000101"]
            # button 1
            words_send = ["01000000",
                          "00000100",
                          "00000001",
                          "00000000",
                          "00001000",
                          "00001001"]
            words_send_inv = [int(negate(w)[::-1], 2) for w in words_send]
            for word in words_send_inv:
                print(word.to_bytes(1, "big"))
                ser.write(word.to_bytes(1, "big"))
            rcv = ser.read(1024)
            if not rcv:
                print("nothing received")
            else:
                word_rcv = int.from_bytes(rcv, byteorder="big")
                word_str = format(word_rcv, "#010b")[2:]
                print("%d bits received" % len(rcv))
                plot_data(list(word_str))


def plot_data(data):
    plt.step([i*8.5 for i in range(len(data))], data)
    plt.yticks(range(2))
    plt.ylabel("signal")
    plt.xlabel("us")
    plt.show()


if __name__ == "__main__":
    test_uart()
