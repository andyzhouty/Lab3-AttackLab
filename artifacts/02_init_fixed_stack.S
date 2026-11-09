# 02_init_fixed_stack.S
# 来源：attack/dark-calc（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc | sed -n '/<init_fixed_stack>:/,/^$/p'
# 说明：以下为 objdump 原始输出，指令一字未改。这是构造函数，用 mmap 分配固定地址的栈，
#       两端各做一页隔离，并把栈顶写入 fixed_stack_top。
0000000000401add <init_fixed_stack>:
  401add:	55                   	push   %rbp
  401ade:	48 89 e5             	mov    %rsp,%rbp
  401ae1:	48 83 ec 20          	sub    $0x20,%rsp
  401ae5:	48 c7 45 f8 00 20 80 	movq   $0x802000,-0x8(%rbp)
  401aec:	00 
  401aed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  401af1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  401af7:	41 b8 ff ff ff ff    	mov    $0xffffffff,%r8d
  401afd:	b9 22 00 10 00       	mov    $0x100022,%ecx
  401b02:	ba 07 00 00 00       	mov    $0x7,%edx
  401b07:	48 89 c6             	mov    %rax,%rsi
  401b0a:	48 bf 00 00 00 00 10 	movabs $0x721000000000,%rdi
  401b11:	72 00 00 
  401b14:	e8 b7 fc ff ff       	call   4017d0 <mmap@plt>
  401b19:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  401b1d:	48 83 7d f0 ff       	cmpq   $0xffffffffffffffff,-0x10(%rbp)
  401b22:	75 14                	jne    401b38 <init_fixed_stack+0x5b>
  401b24:	bf 48 1d 40 00       	mov    $0x401d48,%edi
  401b29:	e8 42 fd ff ff       	call   401870 <perror@plt>
  401b2e:	bf 01 00 00 00       	mov    $0x1,%edi
  401b33:	e8 48 fd ff ff       	call   401880 <exit@plt>
  401b38:	48 b8 00 00 00 00 10 	movabs $0x721000000000,%rax
  401b3f:	72 00 00 
  401b42:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  401b46:	74 44                	je     401b8c <init_fixed_stack+0xaf>
  401b48:	48 8b 05 71 15 20 00 	mov    0x201571(%rip),%rax        # 6030c0 <stderr@GLIBC_2.2.5>
  401b4f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  401b53:	48 b9 00 00 00 00 10 	movabs $0x721000000000,%rcx
  401b5a:	72 00 00 
  401b5d:	be 70 1d 40 00       	mov    $0x401d70,%esi
  401b62:	48 89 c7             	mov    %rax,%rdi
  401b65:	b8 00 00 00 00       	mov    $0x0,%eax
  401b6a:	e8 91 fc ff ff       	call   401800 <fprintf@plt>
  401b6f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  401b73:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  401b77:	48 89 d6             	mov    %rdx,%rsi
  401b7a:	48 89 c7             	mov    %rax,%rdi
  401b7d:	e8 be fc ff ff       	call   401840 <munmap@plt>
  401b82:	bf 01 00 00 00       	mov    $0x1,%edi
  401b87:	e8 f4 fc ff ff       	call   401880 <exit@plt>
  401b8c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  401b90:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  401b94:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  401b98:	48 05 00 10 80 00    	add    $0x801000,%rax
  401b9e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  401ba2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  401ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  401bab:	be 00 10 00 00       	mov    $0x1000,%esi
  401bb0:	48 89 c7             	mov    %rax,%rdi
  401bb3:	e8 a8 fc ff ff       	call   401860 <mprotect@plt>
  401bb8:	83 f8 ff             	cmp    $0xffffffff,%eax
  401bbb:	75 14                	jne    401bd1 <init_fixed_stack+0xf4>
  401bbd:	bf a0 1d 40 00       	mov    $0x401da0,%edi
  401bc2:	e8 a9 fc ff ff       	call   401870 <perror@plt>
  401bc7:	bf 01 00 00 00       	mov    $0x1,%edi
  401bcc:	e8 af fc ff ff       	call   401880 <exit@plt>
  401bd1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  401bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  401bda:	be 00 10 00 00       	mov    $0x1000,%esi
  401bdf:	48 89 c7             	mov    %rax,%rdi
  401be2:	e8 79 fc ff ff       	call   401860 <mprotect@plt>
  401be7:	83 f8 ff             	cmp    $0xffffffff,%eax
  401bea:	75 14                	jne    401c00 <init_fixed_stack+0x123>
  401bec:	bf c0 1d 40 00       	mov    $0x401dc0,%edi
  401bf1:	e8 7a fc ff ff       	call   401870 <perror@plt>
  401bf6:	bf 01 00 00 00       	mov    $0x1,%edi
  401bfb:	e8 80 fc ff ff       	call   401880 <exit@plt>
  401c00:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  401c04:	48 89 05 e5 14 20 00 	mov    %rax,0x2014e5(%rip)        # 6030f0 <fixed_stack_top>
  401c0b:	90                   	nop
  401c0c:	c9                   	leave
  401c0d:	c3                   	ret
