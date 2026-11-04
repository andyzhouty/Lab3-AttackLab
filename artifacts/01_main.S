# 01_main.S
# 来源：attack/dark-calc（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc | sed -n '/<main>:/,/^$/p'
# 说明：以下为 objdump 原始输出，指令一字未改。对应任务 5 的机器码检查。
0000000000401ac3 <main>:
  401ac3:	55                   	push   %rbp
  401ac4:	48 89 e5             	mov    %rsp,%rbp
  401ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  401acc:	e8 a6 fe ff ff       	call   401977 <input>
  401ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  401ad6:	e8 fc fe ff ff       	call   4019d7 <eval>
  401adb:	eb ea                	jmp    401ac7 <main+0x4>
