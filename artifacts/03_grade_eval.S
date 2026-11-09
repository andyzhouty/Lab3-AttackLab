0000000000401a87 <grade_eval>:
  401a87:       push   %rbp
  401a88:       mov    %rsp,%rbp
  401a8b:       sub    $0x10,%rsp
  401a8f:       mov    %edi,-0x4(%rbp)
  401a92:       cmpl   $0x4,-0x4(%rbp)
  401a96:       jne    401ab1 <grade_eval+0x2a>
  401a98:       mov    $0x45,%eax
  401a9d:       sub    -0x4(%rbp),%eax
  401aa0:       mov    %eax,%esi
  401aa2:       mov    $0x401d20,%edi
  401aa7:       mov    $0x0,%eax
  401aac:       call   4017f0 <printf@plt>
  401ab1:       mov    0x2015e8(%rip),%rax        # 6030a0 <stdout@GLIBC_2.2.5>
  401ab8:       mov    %rax,%rdi
  401abb:       call   401830 <fflush@plt>
  401ac0:       nop
  401ac1:       leave
  401ac2:       ret