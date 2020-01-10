#!/usr/bin/env python3

"""Simple GUI for the remote control functionalities."""

from functools import partial
import tkinter as tk
from tkinter import ttk

import uart


# TODO: check the commands from
# https://exploreembedded.com/wiki/NEC_IR_Remote_Control_Interface_with_8051
# commands for kaseikyo:
COMMANDS = {
    "0": 0x400401009899,
    "1": 0x400401000809,
    "2": 0x400401008889,
    "3": 0x400401004849,
    "4": 0x40040100C8C9,
    "5": 0x400401002829,
    "6": 0x40040100A8A9,
    "7": 0x400401006869,
    "8": 0x40040100E8E9,
    "9": 0x400401001819,
    "Vol+": 0x400401000405,
    "Vol-": 0x400401008485,
    "Ch+": 0x400401002C2D,
    "Ch-": 0x40040100ACAD,
    "Up": 0x400401005253,
    "Down": 0x40040100D2D3,
    "Left": 0x400401007273,
    "Right": 0x40040100F2F3,
    "Ok": 0x400401009293,
    "Menu": 0x400401004A4B,
    "Power": 0x40040100BCBD,
    "Mute": 0x400401004C4D,
    "Play": 0x400401900392,
    "Pause": 0x400401908312,
    "Stop": 0x4004019043D2,
    "Forward": 0x40040190C352,
    "Back": 0x4004019023B2,
}


def negate(str_in: str) -> str:
    """Bitwise negate a string of bits."""
    # TODO: Remove duplicated function definition.
    # TODO: figure out why negation is needed. uart and ir rx are low active.
    assert all(character in ["0", "1"] for character in str_in)
    str_in.replace("1", "X").replace("0", "1").replace("X", "0")
    return str_in.replace("1", "X").replace("0", "1").replace("X", "0")


class TabConfigure(ttk.Frame):  # pylint: disable=too-many-ancestors
    """Configure tab of the GUI."""
    def __init__(self, parent):
        super().__init__(parent)
        # TODO: implement


class TabSample(ttk.Frame):  # pylint: disable=too-many-ancestors
    """Sample tab of the GUI."""
    def __init__(self, parent):
        super().__init__(parent)

        btn = ttk.Button(self, text="Start sampling", command=self.sample)
        btn.grid()

    @staticmethod
    def sample():
        """Sample an infrared signal."""
        port = uart.scan()[0]
        uart.receive(port, timeout=5)


class TabRemoteControl(ttk.Frame):  # pylint: disable=too-many-ancestors
    """Remote control tab of the GUI."""
    def __init__(self, parent, codec):
        super().__init__(parent)

        self.current_cmd = None
        self.codec = codec

        self.create_remote_buttons()
        self.send_cmd()

    def create_remote_buttons(self):
        """Create the buttons of the remote control."""
        def add_button(row, col, cmd, text):
            btn = ttk.Button(self, text=text)
            btn.bind("<ButtonPress>", partial(cmd, text=text))
            btn.bind("<ButtonRelease>", self.reset_cmd)
            btn.grid(row=row, column=col)

        row = 1
        add_button(row, 0, self.set_cmd, "Power")
        add_button(row, 2, self.set_cmd, "Mute")

        row += 1
        col = 0
        for text, cmd in zip(("1", "2", "3"), (self.set_cmd,)*3):
            add_button(row, col, cmd, text)
            col += 1

        row += 1
        col = 0
        for text, cmd in zip(("4", "5", "6"), (self.set_cmd,)*3):
            add_button(row, col, cmd, text)
            col += 1

        row += 1
        col = 0
        for text, cmd in zip(("7", "8", "9"), (self.set_cmd,)*3):
            add_button(row, col, cmd, text)
            col += 1

        row += 1
        add_button(row, 1, self.set_cmd, "0")

        row += 1
        add_button(row, 1, self.set_cmd, "Up")

        row += 1
        col = 0
        for text, cmd in zip(("Left", "Ok", "Right"), (self.set_cmd,)*3):
            add_button(row, col, cmd, text)
            col += 1

        row += 1
        add_button(row, 1, self.set_cmd, "Down")

    def reset_cmd(self, event):  # pylint: disable=unused-argument
        self.current_cmd = None

    def set_cmd(self, event, text=""):  # pylint: disable=unused-argument
        """Set a command via GUI."""
        # TODO: add #018b for NEC
        # b'\xfd\xdf\x7f\xff\xefo'
        # convert hex to binary string
        cmd = format(COMMANDS[text], '#050b')[2:]
        # negate the string and revert all bits
        cmd = negate(cmd)[::-1]
        # revert all bytes
        cmd = "".join([cmd[x:x+8] for x in range(0, len(cmd), 8)][::-1])
        self.current_cmd = int(cmd, 2)

    def send_cmd(self):
        """Send the previously set command via UART."""
        if self.current_cmd is not None:
            port = uart.scan()[0]
            bytes_ = 6 if self.codec == "KAS" else 2
            uart.send(port, self.current_cmd, bytes_=bytes_)
        self.after(150, self.send_cmd)


class RemoteGui(tk.Tk):
    """Base class for the remote GUI."""
    def __init__(self, codec):
        super().__init__()
        self.title("Remote control")
        self.geometry("240x320")
        self.rowconfigure(0, weight=1)
        self.columnconfigure(0, weight=1)
        self.codec = codec

        self.create_menu()
        self.create_notebook()

    def create_menu(self):
        menu = tk.Menu(self)
        self.config(menu=menu)
        filemenu = tk.Menu(menu)
        menu.add_cascade(label="File", menu=filemenu)
        filemenu.add_separator()
        filemenu.add_command(label="Exit", command=self.quit)

        # TODO: add small about section
        # helpmenu = tk.Menu(menu)
        # menu.add_cascade(label="Help", menu=helpmenu)
        # helpmenu.add_command(label="About...", command=None)

    def create_notebook(self):
        notebook = ttk.Notebook(self)
        tab1 = TabConfigure(notebook)
        tab2 = TabSample(notebook)
        tab3 = TabRemoteControl(notebook, self.codec)
        notebook.add(tab1, text="Configure")
        notebook.add(tab2, text="Sample")
        notebook.add(tab3, text="Remote")
        notebook.grid(sticky="nsew")


if __name__ == "__main__":
    APP = RemoteGui("KAS")
    APP.mainloop()
