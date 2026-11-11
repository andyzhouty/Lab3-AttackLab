# 05 任务六：Canary

## 1 这一关的形状

目标二进制 `attack/dark-log`，函数只有 `input`、`main` 与 `grade_eval` 三个。目标仍是让 `grade_eval(4)` 打印 `Hope A will be your grade!`。

难点在于栈保护：`input` 的帧里，数组之上、返回地址之前多放了一个随机值，函数返回前会把它与 `%fs:0x28` 比较，不等就调用 `__stack_chk_fail` 终止。直接覆盖返回地址一定会连带改写它，检查必然失败。

这一关的突破口在 `input` 里那条 `memcpy`：它的目的地由结构体里的 `len` 字段决定，而 `len` 位于数组之后，会被输入覆盖。

```c
struct log_frame {
  char expression[128];
  char logMsg[128];
  int len;
  char pad[8];
};

void input(void) {
  struct log_frame f;
  f.len = 0;
  gets(f.expression);                                   // 无长度检查
  memcpy(f.logMsg + f.len, f.expression, sizeof(f.expression));  // 目的地可被控制
}
```

## 2 进度清单

- [ ] Q1 确认 canary 的位置与检查方式
- [ ] Q2 量出结构体各字段相对帧基址的偏移
- [ ] Q3 说明 `len` 如何影响 `memcpy` 的目的地
- [ ] Q4 选定 `len` 的取值，并解释为什么不会破坏 canary
- [ ] Q5 构造链条与填充，确认总长
- [ ] Q6 生成 `payload_canary.py` 并测试

## 3 命令速查

```bash
objdump -d --no-show-raw-insn attack/dark-log | sed -n '/<input>:/,/^$/p'
objdump -d --no-show-raw-insn attack/dark-log | sed -n '/<grade_eval>:/,/^$/p'
nm attack/dark-log | grep -E "grade_eval|input|main"

# 取 .text 字节并确认段起始地址
readelf -SW attack/dark-log | grep " .text "
objcopy -O binary --only-section=.text attack/dark-log /tmp/log.bin
python3 - <<'PY'
import re
d = open("/tmp/log.bin", "rb").read()
base = 0x401590
for m in re.finditer(b"\x5f\xc3", d):
    print(hex(base + m.start()))
PY

# 停在 canary 检查之前，观察帧内数据
gdb -batch -q -ex 'set pagination off' -ex 'break *0x4017df' \
    -ex 'run < /tmp/can.bin' -ex 'p/x $rbp' -ex 'x/6gx $rbp-0x10' ./attack/dark-log
```

完整反汇编已导出为 `artifacts/05_dark-log.S`，`.text` 起始地址 `0x401590`，四个关键位置：`grade_eval` 在 `0x401677`、`input` 在 `0x4016d6`、`main` 在 `0x4017f5`、`__libc_csu_init` 在 `0x401840`。

## 4 待回答的问题

### Q1 canary 在哪、怎么查

在 `input` 的反汇编里找 `mov %fs:0x28, ...` 与结尾的 `xor %fs:0x28, ...`。前者把 canary 存进帧内某一格，后者在返回前比较。
前者位于`0x4016e1`，后者位于`0x4017e3`

提示：它存在 `-0x8(%rbp)`；比较不等时调用 `__stack_chk_fail`。记下这两条指令的地址，后面要用它们确认程序走到了哪一步。

### Q2 各字段的偏移

数组从 `rbp-0x120` 开始，`sub $0x120,%rsp` 能看出帧大小。结合结构体声明，算出三个数：`len` 字段相对数组首字节的偏移、canary 相对数组首字节的偏移、返回地址相对数组首字节的偏移。
`sub $0x120,%rsp` 意味着帧大小为288字节，len字段相对数组首字节的偏移为256，canary相对数组首字节的偏移为280，返回地址相对偏移为296

提示：`expression` 占 128，`logMsg` 占 128，`len` 是 4 字节的 `int`，之后还有 8 字节 `pad`。canary 在 `-0x8(%rbp)`，返回地址在 `+0x8(%rbp)`。

### Q3 `len` 控制了什么

反汇编里 `memcpy` 被展开成一串 `mov`，目的地址的算法是“`rbp-0x120` 加 `0x80` 再加 `len`”。也就是说目的地等于 `logMsg` 的起点加上 `len`。

这一步的意义：复制源是数组开头，长度固定 128，只有目的地随 `len` 变化。改 `len` 就能让这 128 字节落到帧内任意位置。

`len` 在复制之前被读走。反汇编里 `0x401719` 那条 `mov -0x20(%rbp),%eax` 取的就是`len`，而这个位置在数组之后，会被输入覆盖。

`len` 会决定目的地。目的地址等于数组首字节加 `0x80` 再加 `len`，后两项里 `0x80` 是 `logMsg` 的固定偏移，`len` 是变量。复制源是数组开头、长度固定 128 字节，仅目的地可变。改 `len` 能让这 128 字节落到帧内任意位置，让目的地跳过它就是我们绕过 canary 的办法。

### Q4 `len` 取多少

要让这 128 字节覆盖返回地址，同时不碰到 canary。

提示：目的地要从返回地址那一格开始，所以 `len` 等于“返回地址偏移减去 `logMsg` 的偏移”。canary 在返回地址下面 16 字节处，只要目的地不低于它，复制就不会碰它。
len应该取`rbp+8`与`rbp-0xa0`的差值，即168

### Q5 链条与总长

链条与上一关相同：片段地址、参数 4、`grade_eval` 地址，共 24 字节，放在数组开头。之后填充到 `len` 字段的位置，写入 `len` 的值，再填充到零字节落点之前。

提示：`grade_eval` 在 `0x401677`，`pop %rdi; ret` 用上面的字节搜索找，注意 `.text` 的起始地址是 `0x401590`，不要套用上一个二进制的 `0x401700`。

### Q6 测试

```bash
python3 payload_canary.py > /tmp/can.bin
cd attack && ./dark-log < /tmp/can.bin
```

预期输出 `Hope A will be your grade!`，随后段错误。

## 5 观察记录表

| 项目                   | 值                                             |
| ---------------------- | ----------------------------------------------- |
| canary 存放位置        | `rbp-0x8`，相对数组首字节偏移 280              |
| canary 检查指令        | `0x4017df` 读回、`0x4017e3` 异或比较            |
| `len` 字段偏移       | 256（`rbp-0x20`）                              |
| canary 偏移            | 280（`rbp-0x8`）                               |
| 返回地址偏移           | 296（`rbp+8`）                                 |
| 选定的 `len` 值      | 168（`0xa8`）                                  |
| `pop %rdi; ret` 地址 | `0x4018a3`                                     |
| payload 总长           | 261 字节（24 加 232 加 4 加 1）               |
| 运行输出               | `Hope A will be your grade!`（行首带一个空格），随后 `SIGSEGV`，退出码 139 |

## 6 已确认结论

- canary 存放在 `rbp-0x8`，由 `0x4016e1` 读入、`0x4017e3` 比较，不等时调用 `__stack_chk_fail`。
- 结构体各字段相对数组首字节的偏移为：`logMsg` 128、`len` 256、`pad` 260、canary 280、返回地址 296。
- `memcpy` 的目的地址等于数组首字节加 `0x80` 再加 `len`，`len` 位于偏移 256，可被输入改写。
- `len` 取 168 时，复制的起点落在返回地址那一格，128 字节的链条写进返回地址之后的区域，canary 未被触碰。
- 片段 `pop %rdi; ret` 位于 `0x4018a3`，是 `__libc_csu_init` 尾部 `pop %r15; ret` 中的第二个字节起。
- `payload_canary.py` 生成的 261 字节让程序输出 `Hope A will be your grade!`，随后以 `SIGSEGV` 结束。

## 7 备忘

报告方面：这一关占 10 分报告分。重点写清三件事：canary 的检查机制、为什么直接覆盖会被发现、`len` 为什么能绕过它（复制目的地可控，且零字节落点恰好是 canary 的最低位）。

容易卡住的地方：偏移算错一格，链条就落在 canary 上；`.text` 起始地址每个二进制不同，搜到的片段地址要用 `readelf` 给出的基址换算；`gets` 的补零位置要单独确认。

`payload_canary.py` 的目标是 `attack/dark-log`，CI 期望的输出与上一关相同。
