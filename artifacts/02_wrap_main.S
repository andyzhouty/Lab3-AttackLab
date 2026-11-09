# 02_wrap_main.S
# 来源：attack/dark-calc（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc | sed -n '/<__wrap_main>:/,/^$/p'
# 说明：以下为 objdump 原始输出，指令一字未改。这是链接器用 --wrap=main 生成的包装函数，
#       它把 rsp 换成固定的栈顶，再调用真正的 main。
0000000000401c0e <__wrap_main>:
  401c0e:	41 54                	push   %r12
  401c10:	49 89 e4             	mov    %rsp,%r12
  401c13:	48 8b 25 d6 14 20 00 	mov    0x2014d6(%rip),%rsp        # 6030f0 <fixed_stack_top>
  401c1a:	e8 a4 fe ff ff       	call   401ac3 <main>
  401c1f:	4c 89 e4             	mov    %r12,%rsp
  401c22:	41 5c                	pop    %r12
  401c24:	c3                   	ret
  401c25:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  401c2c:	00 00 00 
  401c2f:	90                   	nop
