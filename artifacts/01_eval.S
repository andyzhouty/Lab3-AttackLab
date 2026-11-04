# 01_eval.S
# 来源：attack/dark-calc（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc | sed -n '/<eval>:/,/^$/p'
# 说明：以下为 objdump 原始输出，指令一字未改。截断与拼接命令串的逻辑都在这里。
00000000004019d7 <eval>:
  4019d7:	55                   	push   %rbp
  4019d8:	48 89 e5             	mov    %rsp,%rbp
  4019db:	48 83 ec 10          	sub    $0x10,%rsp
  4019df:	bf d0 30 60 00       	mov    $0x6030d0,%edi
  4019e4:	e8 d7 fd ff ff       	call   4017c0 <strlen@plt>
  4019e9:	48 83 f8 0f          	cmp    $0xf,%rax
  4019ed:	77 0c                	ja     4019fb <eval+0x24>
  4019ef:	bf d0 30 60 00       	mov    $0x6030d0,%edi
  4019f4:	e8 c7 fd ff ff       	call   4017c0 <strlen@plt>
  4019f9:	eb 05                	jmp    401a00 <eval+0x29>
  4019fb:	b8 0f 00 00 00       	mov    $0xf,%eax
  401a00:	89 45 fc             	mov    %eax,-0x4(%rbp)
  401a03:	8b 45 fc             	mov    -0x4(%rbp),%eax
  401a06:	83 c0 01             	add    $0x1,%eax
  401a09:	48 98                	cltq
  401a0b:	b9 d8 30 60 00       	mov    $0x6030d8,%ecx
  401a10:	48 89 c2             	mov    %rax,%rdx
  401a13:	be d0 30 60 00       	mov    $0x6030d0,%esi
  401a18:	48 89 cf             	mov    %rcx,%rdi
  401a1b:	e8 30 fe ff ff       	call   401850 <memmove@plt>
  401a20:	ba 08 00 00 00       	mov    $0x8,%edx
  401a25:	be c0 1c 40 00       	mov    $0x401cc0,%esi
  401a2a:	bf d0 30 60 00       	mov    $0x6030d0,%edi
  401a2f:	e8 dc fd ff ff       	call   401810 <memcpy@plt>
  401a34:	8b 45 fc             	mov    -0x4(%rbp),%eax
  401a37:	48 98                	cltq
  401a39:	48 83 c0 08          	add    $0x8,%rax
  401a3d:	48 05 d0 30 60 00    	add    $0x6030d0,%rax
  401a43:	0f b7 15 7f 02 00 00 	movzwl 0x27f(%rip),%edx        # 401cc9 <wrapper_back>
  401a4a:	66 89 10             	mov    %dx,(%rax)
  401a4d:	0f b6 15 77 02 00 00 	movzbl 0x277(%rip),%edx        # 401ccb <wrapper_back+0x2>
  401a54:	88 50 02             	mov    %dl,0x2(%rax)
  401a57:	be d0 30 60 00       	mov    $0x6030d0,%esi
  401a5c:	bf 10 1d 40 00       	mov    $0x401d10,%edi
  401a61:	b8 00 00 00 00       	mov    $0x0,%eax
  401a66:	e8 85 fd ff ff       	call   4017f0 <printf@plt>
  401a6b:	bf d0 30 60 00       	mov    $0x6030d0,%edi
  401a70:	e8 6b fd ff ff       	call   4017e0 <system@plt>
  401a75:	48 8b 05 24 16 20 00 	mov    0x201624(%rip),%rax        # 6030a0 <stdout@GLIBC_2.2.5>
  401a7c:	48 89 c7             	mov    %rax,%rdi
  401a7f:	e8 ac fd ff ff       	call   401830 <fflush@plt>
  401a84:	90                   	nop
  401a85:	c9                   	leave
  401a86:	c3                   	ret
