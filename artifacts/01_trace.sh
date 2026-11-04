#!/usr/bin/env bash
# 01_trace.sh —— 观察 gets 前后栈上的字节变化
#
# 用法：./artifacts/01_trace.sh <输入长度>
#   例：./artifacts/01_trace.sh 3
#       ./artifacts/01_trace.sh 24
#
# 做的事：生成由若干个 '1' 组成的输入，停在 input+35（call gets 那条），
# 打印写入前和写入后的内存快照，然后退出。
#
# 只使用 break / run / printf / x / set（便利变量），不修改寄存器或内存。
# 断点选在 input+35 的原因：此时 lea 与 mov 已经执行完，rdi 里就是缓冲区地址，
# 而 gets 还没有被调用；执行一条 ni 之后就能拿到写入完成的状态。

set -euo pipefail

n=${1:-}
if [[ -z "$n" ]]; then
    echo "用法：$0 <输入长度>" >&2
    exit 2
fi

repo=$(cd "$(dirname "$0")/.." && pwd)
bin="$repo/attack/dark-calc"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python3 -c 'import sys; sys.stdout.write("1" * int(sys.argv[1]) + "\n")' "$n" > "$tmp/in.txt"

gdb -batch -q \
    -ex 'set pagination off' \
    -ex 'break *input+35' \
    -ex "run < $tmp/in.txt" \
    -ex 'set $buf = $rdi' \
    -ex 'set $frame = $rbp' \
    -ex 'printf "\n===== 写入前（gets 尚未执行）=====\n"' \
    -ex 'printf "输入长度 = %d，缓冲区 = %p，rbp = %p，rsp = %p\n", '"$n"', $buf, $frame, $rsp' \
    -ex 'x/32xb $buf' \
    -ex 'x/2gx $frame' \
    -ex 'ni' \
    -ex 'printf "\n===== 写入后（gets 已返回）=====\n"' \
    -ex 'x/32xb $buf' \
    -ex 'x/2gx $frame' \
    -ex 'printf "保存的 rbp = %#lx   返回地址 = %#lx\n", *(unsigned long*)$frame, *(unsigned long*)($frame+8)' \
    "$bin"
