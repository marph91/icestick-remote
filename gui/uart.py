#!/usr/bin/env python3

"""Module for providing UART functionalities."""

import serial
import serial.tools.list_ports

import matplotlib.pyplot as plt
plt.switch_backend("TkAgg")


def scan() -> list:
    """Scan for serial ports and filter the icestick port."""
    ports = list(serial.tools.list_ports.grep("0403:6010"))
    return ports


def send(port, word: int, bytes_: int = 1):
    """Send data to a serial port."""
    with serial.Serial(port.device, baudrate=115200) as ser:
        ser.write(word.to_bytes(bytes_, "big"))


def plot_data(data: list):
    """Simple plot for the UART data."""
    plt.step([i*8.5 for i in range(len(data))], data)
    plt.yticks(range(2))
    plt.ylabel("signal")
    plt.xlabel("us")
    plt.show()


def receive(port, timeout: float = 0.15):
    """Try to receive data from a serial port until the data is available
    or the timeout is reached."""
    with serial.Serial(port.device, baudrate=115200, timeout=timeout) as ser:
        rcv = ser.read(1024)
        if not rcv:
            print("received nothing")
        else:
            word_rcv = int.from_bytes(rcv, byteorder="big")
            word_str = format(word_rcv, "#010b")[2:]
            print("received %d bits" % len(rcv))
            plot_data(list(word_str))


if __name__ == "__main__":
    DEVICES = scan()
    receive(DEVICES[0], timeout=10)
