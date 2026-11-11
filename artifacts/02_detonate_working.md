# 02 任务三：利用缓冲区漏洞执行 ./malware

## 1 这一关的形状

被攻击的程序仍是 `attack/dark-calc`，与阶段一同一份二进制，指令没有变化。区别在于阶段一只是观察越界写到了哪里，这一关要让越界写改变控制流，最终让 `./malware` 被 `dark-calc` 启动。

除阶段一已经看过的 `input`、`eval`、`main` 三个函数，这份二进制里还有几处此前没注意的构造：

| 符号                 | 地址         | 作用                                                          |
| -------------------- | ------------ | ------------------------------------------------------------- |
| `__wrap_main`      | `0x401c0e` | 真正的入口，先把栈指针换到一个固定区域，再调用 `main`       |
| `init_fixed_stack` | `0x401add` | 构造函数，用 `mmap` 分配一块固定地址的栈并设置权限          |
| `fixed_stack_top`  | `0x6030f0` | 保存那块栈的顶端地址                                          |
| `grade_eval`       | `0x401a87` | 打印 "Hope A will be your grade!"，本关用不到，后面两关会用到 |

前两个函数的完整反汇编已经单独导出：`artifacts/02_wrap_main.S` 与 `artifacts/02_init_fixed_stack.S`，格式与阶段一那几份一致。

需要用的知识点：栈段的权限、返回地址的位置、机器码的构造、`execve` 与 `system` 的差别、进程的父子关系。

## 2 进度清单

- [ ] Q1 看清本程序栈段的地址范围与权限
- [ ] Q2 弄清 `__wrap_main` 与 `init_fixed_stack` 做了什么，栈地址为什么每次一样
- [ ] Q3 算出缓冲区首字节到返回地址的距离，确认要写的目标地址
- [ ] Q4 决定 payload 的构成与长度
- [ ] Q5 弄清 `malware` 凭什么判断自己是被 `dark-calc` 启动的
- [ ] Q6 写出 `payload.py` 并在本地跑通

## 3 命令速查

```bash
# 栈段在文件头里的标记
readelf -lW attack/dark-calc | grep -A1 GNU_STACK

# 运行时真实的映射与权限
gdb -batch -q -ex 'set pagination off' -ex 'break main' -ex 'run' \
    -ex 'info proc mappings' -ex 'p/x $rsp' ./attack/dark-calc

# 启动流程
objdump -d --no-show-raw-insn attack/dark-calc | sed -n '/<__wrap_main>:/,/^$/p'
objdump -d --no-show-raw-insn attack/dark-calc | sed -n '/<init_fixed_stack>:/,/^$/p'

# 判定脚本
cat attack/malware

# mmap 调用前一刻的六个参数
gdb -batch -q -ex 'set pagination off' -ex 'break *0x401b14' -ex 'run' \
    -ex 'info registers rdi rsi rdx rcx r8 r9' ./attack/dark-calc

# 阶段一的观察脚本仍然可用
./artifacts/01_trace.sh 24
```

## 4 待回答的问题

### Q1 栈段是什么权限

在 GDB 里停在 `main` 之后执行 `info proc mappings`，找到 `$rsp` 所在的那一段，记下起止地址与权限位。再用同样的命令看一眼 `attack/dark-calc-nx`。

`attack/dark-calc`: 起止地址分别是`0x0000721000001000` `0x0000721000801000`，权限位`rwxp`

`attack/dark-calc-nx`: 起止地址分别是`0x00007ffffffdd000` `0x00007ffffffff000`，权限位`rw-p`

### Q2 栈地址为什么固定

反汇编 `__wrap_main`，看它在调用 `main` 之前改了什么寄存器、改成了哪个值；反汇编 `init_fixed_stack`，看它向 `mmap` 传了哪几个参数（长度、权限、标志），以及两次 `mprotect` 保护的是哪两页。

标志位是多位按位或出来的一个数，逐位拆开才读得懂。定义在 `/usr/include/x86_64-linux-gnu/bits/` 下与 `mman` 有关的头文件里，`grep MAP_ 那些文件` 可以对照。

提示：`info proc mappings` 里那块 8 MB 区域前后各有一段 `---p`，那是防止越界访问的隔离页。

在`__wrap_main`中，在调用`main`之前对寄存器的更改是

1. 将`r12`的值压入栈顶，将`rsp`-8
2. 将`%rip+0x2014d6`的结果装入到`rsp`

`init_fixed_stack`向`mmap`传递的参数是：

`rdi`: `$0x721000000000`

`rsi`: `rbp-8`即`$0x802000`

`rdx`: `$0x7`

`rcx`: `$0x100022`

`r8`:  `$0xffffffff`

`r9`: `$0x0`
长度：`$0x802000`
权限为0x7，可读可写可执行

标志`0x02` 是 `MAP_PRIVATE`，`0x20` 是 `MAP_ANONYMOUS`，`0x100000` 是 `MAP_FIXED_NOREPLACE`

### Q3 目标地址写多少

停到 `input+94`（`leave`）之前，打印 `$rsp`、`$rbp`，再执行 `p/x $rbp-0x10`。根据阶段一的结论，数组首字节到返回地址相隔 24 字节，返回地址那一格在 `$rbp+8`。

```asm
rsp=0x721000800fd0 rbp=0x721000800fe0 buf=0x721000800fd0
```

提示：这一关要让程序从数组首字节开始执行，所以返回地址这一格要填的值，就是数组首字节的地址。写成 8 字节小端序。

### Q4 payload 怎么排

payload 由三部分组成：要执行的机器码、填充到第 24 字节的占位内容、覆盖返回地址的 8 个字节。总长度至少 32 字节，末尾还要一个换行符结束 `gets`。

提示：机器码放在数组开头，所以长度要小于 24；`gets` 遇到 `0x0a` 会停，payload 里不能出现换行字节；机器码里出现 `0x00` 不影响写入，`strcpy` 会在那里截断，控制流已经由 `gets` 写完的字节决定了。

### Q5 `malware` 怎么判断

打开 `attack/malware`，看它沿 `ps -o ppid` 往上找什么。

一直会往上找父进程，找到dark-calc才算通过

### Q6 怎么测

`payload.py` 要把二进制写到标准输出，不能夹杂任何提示文字。CI 运行时的工作目录是 `attack/`，所以脚本里写 `./malware` 是相对那个目录。

本地复现：

```bash
python3 payload.py | ./attack/dark-calc
```

提示：在仓库根目录运行时，`./malware` 不一定存在，测试时可以先 `cd attack` 再 `../payload.py` 那种写法；先确认路径，再判断是 payload 的问题还是路径的问题。

## 5 观察记录表

栈段：

| 项目                     | 值                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------- |
| `$rsp` 所在区域起止    | `0x721000001000` 到 `0x721000801000`，跨度 `0x800000`，即 8 MB               |
| 该区域权限               | `rwxp`，可读、可写、可执行                                                       |
| `fixed_stack_top` 的值 | `0x721000801000`，正好是区域上界；`main` 入口处 `$rsp` 为 `0x721000800ff0` |

上下各有一页 `---p` 的隔离页，分别是 `0x721000000000` 到 `0x721000001000`、`0x721000801000` 到 `0x721000802000`。对照 `attack/dark-calc-nx`，`$rsp` 落在 `0x7fff` 区域的 `[stack]` 段，权限为 `rw-p`，没有可执行位。

帧内位置：

| 项目                  | 值             |
| --------------------- | -------------- |
| 数组首字节地址        | 0x721000800fd0 |
| 保存的 `rbp` 所在格 | 0x721000800fe0 |
| 返回地址所在格        | 0x721000800fe8 |
| 到返回地址的字节数    | 24             |

payload：

| 项目       | 值                                                        |
| ---------- | ---------------------------------------------------------- |
| 机器码长度 | 22 字节（两条 `movabs` 加一条 `call *%rax`）             |
| 填充长度   | 2 字节 `0x90`                                            |
| 总长度     | 43 字节（22 加 2 加 8 加 10 加 1）                      |
| 运行结果   | 输出 `### You have successfully detonated the bomb! Congratulations! ###`，随后 `SIGSEGV`，退出码 139 |

## 6 已确认结论

- `dark-calc` 的栈是一块固定地址的 8 MB 可执行内存，起止为 `0x721000001000` 到 `0x721000801000`，权限 `rwxp`，由 `init_fixed_stack` 在构造阶段 `mmap` 得到。
- `__wrap_main` 在调用 `main` 之前把 `rsp` 换成 `fixed_stack_top`（`0x721000801000`），因此 `input` 的帧地址每次运行都一样，`rbp` 为 `0x721000800fe0`，数组首字节为 `0x721000800fd0`。
- 从数组首字节到返回地址相隔 24 字节：16 字节数组加 8 字节保存的 `rbp`。
- `malware` 沿父进程链向上查找 `comm` 等于 `dark-calc` 的进程，因此必须保留 `dark-calc` 进程，`system` 可用，`execve` 不可用。
- 三条指令（两条 `movabs` 加一条 `call *%rax`）共 22 字节，填充两个 `NOP` 后放进前 24 字节，返回地址填 `0x721000800fd0`，字符串放在偏移 32 处。
- `payload.py` 生成的 43 字节让程序输出 `### You have successfully detonated the bomb! Congratulations! ###`，随后因无合法返回地址以 `SIGSEGV` 结束。

## 7 备忘

报告方面：这一关占 5 分报告分，要写清思路、payload 三段的结构、以及终端里 `### You have successfully detonated the bomb! ###` 的输出截图。即使测试没通过，思路与尝试也要写。

容易出错的地方：

地址要按小端序写成 8 字节，写反了程序会跳到无映射地址；payload 里出现 `0x0a` 会被 `gets` 截断；`strcpy` 遇到 `0x00` 会截断，但 `gets` 已经把全部字节写进栈里，控制流不受影响；工作目录不对时 `./malware` 找不到，症状与 payload 写错很像；`system` 会 `fork` 一个 shell，祖先链上仍有 `dark-calc`，`execve` 直接替换当前进程，祖先链更短。

下一关（栈空间执行）才会用到 `grade_eval`，这一关先不管它。
