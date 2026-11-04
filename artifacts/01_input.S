# 01_input.S
# 来源：attack/dark-calc（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc | sed -n '/<input>:/,/^$/p'
# 说明：以下为 objdump 原始输出，指令一字未改。逐条注释的副本见 01_input_annotated.S。

0000000000401977 <input>:
  401977:	55                   	push   %rbp
  401978:	48 89 e5             	mov    %rsp,%rbp
  40197b:	48 83 ec 10          	sub    $0x10,%rsp
  40197f:	be 0f 00 00 00       	mov    $0xf,%esi
  401984:	bf e8 1c 40 00       	mov    $0x401ce8,%edi
  401989:	b8 00 00 00 00       	mov    $0x0,%eax
  40198e:	e8 5d fe ff ff       	call   4017f0 <printf@plt>
  401993:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  401997:	48 89 c7             	mov    %rax,%rdi
  40199a:	e8 81 fe ff ff       	call   401820 <gets@plt>
  40199f:	48 85 c0             	test   %rax,%rax
  4019a2:	74 0b                	je     4019af <input+0x38>
  4019a4:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  4019a8:	0f b6 00             	movzbl (%rax),%eax
  4019ab:	84 c0                	test   %al,%al
  4019ad:	75 14                	jne    4019c3 <input+0x4c>
  4019af:	bf d0 1c 40 00       	mov    $0x401cd0,%edi
  4019b4:	e8 f7 fd ff ff       	call   4017b0 <puts@plt>
  4019b9:	bf 00 00 00 00       	mov    $0x0,%edi
  4019be:	e8 bd fe ff ff       	call   401880 <exit@plt>
  4019c3:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  4019c7:	48 89 c6             	mov    %rax,%rsi
  4019ca:	bf d0 30 60 00       	mov    $0x6030d0,%edi
  4019cf:	e8 cc fd ff ff       	call   4017a0 <strcpy@plt>
  4019d4:	90                   	nop
  4019d5:	c9                   	leave
  4019d6:	c3                   	ret

