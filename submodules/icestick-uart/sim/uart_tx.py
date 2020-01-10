#!/usr/bin/python3

"""Simple UART sender."""

import os
import pty
import time
from random import randint
import serial
import serial.tools.list_ports


def test_uart():
    """Test whether an UART transmission on the serial port works."""
    available_ports = list(serial.tools.list_ports.grep("0403:6010"))
    print("%d serial ports found." % len(available_ports))

    for port in available_ports:
        print("port ", port.device)
        with serial.Serial(port.device, baudrate=115200, timeout=0.1) as ser:
            words = list(range(100)) + [randint(0, 255) for _ in range(100)]
            for word in words:
                ser.write(word.to_bytes(1, "big"))
                rcv = ser.read(1)
                word_rcv = int.from_bytes(rcv, byteorder="big")
                print(format(word, "#010b"), format(word_rcv, "#010b"),
                      word == word_rcv)
                time.sleep(0.001)


def test_uart_sim():
    master, slave = pty.openpty()
    s_name = os.ttyname(slave)
    ser = serial.Serial(s_name)
    print("port ", s_name)
    with serial.Serial(s_name, baudrate=115200, timeout=0.1) as ser:
        for word in range(2**8):
            ser.write(word.to_bytes(1, "big"))
            rcv = os.read(master, 1)
            word_rcv = int.from_bytes(rcv, "big")
            print(format(word, "#010b"), format(word_rcv, "#010b"),
                  word == word_rcv)
            time.sleep(0.001)


if __name__ == "__main__":
    test_uart()
