# 04 任务五：ROP

## 1 这一关的形状

目标二进制换成 `attack/dark-calc-nx`，函数结构与 `dark-calc` 相近，`input`、`eval`、`grade_eval`、`main` 都在，`grade_eval` 的入口是 `0x401978`。

差别在栈：这份二进制的 `GNU_STACK` 标记为 `RW`，运行时的栈段是 `rw-p`，没有可执行位。前面两关“把机器码放进数组再跳过去”的做法在这里会直接触发段错误，因为 CPU 拒绝从不可执行的内存取指。

可行的路子是把程序里现成的指令片段串起来用，这就是 ROP。每个片段以 `ret` 结尾，返回地址那格依次指向它们，形成一条链。

| 需要的信息          | 来源                                             |
| ------------------- | ------------------------------------------------ |
| `grade_eval` 入口 | `nm attack/dark-calc-nx \| grep grade_eval`     |
| 栈是否可执行        | `readelf -lW` 与 GDB 的 `info proc mappings` |
| 可用的指令片段      | 扫描 `.text` 段的字节                          |

完整反汇编已导出为 `artifacts/04_dark-calc-nx.S`，指令一字未改，按地址查片段时直接打开这份文件。

## 2 进度清单

- [ ] Q1 确认栈不可执行
- [ ] Q2 找到把数值装进 `%edi` 的片段
- [ ] Q3 设计返回地址之后的链条排布
- [ ] Q4 说明为什么不需要知道栈地址
- [ ] Q5 写出 `payload_rop.py` 并测试

## 3 命令速查

```bash
# 保护
readelf -lW attack/dark-calc-nx | grep -A1 GNU_STACK
gdb -batch -q -ex 'set pagination off' -ex 'break main' -ex 'run' \
    -ex 'p/x $rsp' -ex 'info proc mappings' ./attack/dark-calc-nx

# 符号
nm attack/dark-calc-nx | grep -E "grade_eval|input|eval|main"

# 取出 .text 的字节，便于搜索片段
objcopy -O binary --only-section=.text attack/dark-calc-nx /tmp/nx.bin
xxd /tmp/nx.bin | head -5

# 在字节流里找 pop %rdi; ret（机器码 5f c3）
python3 - <<'PY'
import re
d = open("/tmp/nx.bin", "rb").read()
base = 0x401700          # .text 段的虚拟地址
for m in re.finditer(b"\x5f\xc3", d):
    print(hex(base + m.start()))
PY

# 确认找到的地址确实是指令边界
objdump -d --start-address=0x401a30 --stop-address=0x401a38 attack/dark-calc-nx
```

## 4 待回答的问题

### Q1 栈还能不能执行

用 `readelf -lW` 看 `GNU_STACK` 那一行的标志位，再用 GDB 看 `$rsp` 所在段的权限。与 `dark-calc` 对比，差在哪一位。
GNU_STACK行的标志位是RW，`$rsp`所在段的权限是`rw-p`。
而`dark-calc`中栈段为`rwxp`，具有`x`，可执行

提示：`RW` 与 `RWE` 的区别就是可执行位；`dark-calc` 的栈是 `mmap` 出来的匿名段，`dark-calc-nx` 用的是常规 `[stack]`。

### Q2 怎么把 4 送进参数寄存器

`grade_eval` 从 `%edi` 取参数。要调用它，需要先有一条指令把 4 装进 `%rdi`。程序里未必有现成的 `pop %rdi; ret`，可以用字节搜索找找。
起始地址位于`0x401a33`

提示：`pop %rdi` 的机器码是 `5f`，`ret` 是 `c3`。找到之后用 `objdump --start-address` 从那个地址开始反汇编，确认那两条确实是指令，而不是某条指令中间的字节。

### Q3 链条怎么排

返回地址那格（偏移 24）之后，栈上接着要放几个 8 字节的值。按“取出 gadget、给它参数、跳到目标函数”的顺序排。
偏移 24 是片段地址、32 是参数 4、40 开始是 `grade_eval`。

提示：`pop %rdi; ret` 执行时会从栈上取走一个 8 字节作为 `%rdi`，然后 `ret` 再取走一个作为下一条指令地址。所以链条是“片段地址、参数、目标地址”三个 8 字节。

### Q4 为什么不需要栈地址

栈受 ASLR 影响，每次运行地址都不同。这条链上没有出现任何栈地址，为什么仍然能成功？
代码段地址、立即数（4）和代码段地址，均不来自栈。`gets` 写完后，`ret` 从栈顶取一个值，之后每一步都由 `rsp` 依次往后。由于位置的相对性，即使 ASLR 每次给栈换一个地址，链条的顺序与内容都不受影响。

### Q5 测试

把链条拼成输入，长度是 24 加 24 再加 1，填充部分不能含 `0x0a`。

```bash
cd attack && ./dark-calc-nx < /tmp/rop.bin
```

预期输出红色的 `Hope A will be your grade!`，随后段错误。

## 5 观察记录表

| 项目                       | 值                                                             |
| -------------------------- | -------------------------------------------------------------- |
| `GNU_STACK` 标志         | `RW`                                                         |
| 栈段权限                   | `rw-p`                                                       |
| `grade_eval` 入口        | `401978`                                                     |
| `pop %rdi; ret` 所在地址 | `0x401a33`，位于`__libc_csu_init`尾部`pop %r15; ret`中间 |
| payload 总长               | 24+24+1=49                                                     |
| 运行输出                   | Hope A will be your grade! zsh: segmentation fault             |

## 6 已确认结论

做成一条写一条，附验证方式。

## 7 备忘

报告方面：这一关占 10 分报告分，比前两关重。需要写清“为什么栈不可执行就换思路”“链条每一段的作用”“为什么不需要栈地址”，最好配一张链条示意图。

容易出错的地方：片段地址要按 8 字节小端写；`pop %rdi; ret` 可能是从某条指令中间开始的，要确认它能正确执行；填充字节不能含 `0x0a`；`grade_eval` 返回后程序会继续跑栈上的垃圾数据，最后崩溃属于正常。

`payload_rop.py` 对应的目标二进制是 `attack/dark-calc-nx`，CI 期望的输出与上一关相同。
