# 04_dark-calc-nx.S
# 来源：attack/dark-calc-nx（课程提供的二进制，未自行编译）
# 导出命令：
#   objdump -d attack/dark-calc-nx
# 说明：以下为 objdump 原始输出，指令一字未改。这一关要找的指令片段散布在各函数之间，
#       因此保留完整反汇编，方便按地址检索；关键函数为 input、eval、grade_eval、main
#       与 __libc_csu_init。


attack/dark-calc-nx：     文件格式 elf64-x86-64


Disassembly of section .init:

0000000000401620 <_init>:
  401620:	48 83 ec 08          	sub    $0x8,%rsp
  401624:	48 8b 05 cd 09 20 00 	mov    0x2009cd(%rip),%rax        # 601ff8 <__gmon_start__>
  40162b:	48 85 c0             	test   %rax,%rax
  40162e:	74 02                	je     401632 <_init+0x12>
  401630:	ff d0                	call   *%rax
  401632:	48 83 c4 08          	add    $0x8,%rsp
  401636:	c3                   	ret

Disassembly of section .plt:

0000000000401640 <.plt>:
  401640:	ff 35 c2 09 20 00    	push   0x2009c2(%rip)        # 602008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401646:	ff 25 c4 09 20 00    	jmp    *0x2009c4(%rip)        # 602010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40164c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401650 <strcpy@plt>:
  401650:	ff 25 c2 09 20 00    	jmp    *0x2009c2(%rip)        # 602018 <strcpy@GLIBC_2.2.5>
  401656:	68 00 00 00 00       	push   $0x0
  40165b:	e9 e0 ff ff ff       	jmp    401640 <.plt>

0000000000401660 <puts@plt>:
  401660:	ff 25 ba 09 20 00    	jmp    *0x2009ba(%rip)        # 602020 <puts@GLIBC_2.2.5>
  401666:	68 01 00 00 00       	push   $0x1
  40166b:	e9 d0 ff ff ff       	jmp    401640 <.plt>

0000000000401670 <strlen@plt>:
  401670:	ff 25 b2 09 20 00    	jmp    *0x2009b2(%rip)        # 602028 <strlen@GLIBC_2.2.5>
  401676:	68 02 00 00 00       	push   $0x2
  40167b:	e9 c0 ff ff ff       	jmp    401640 <.plt>

0000000000401680 <system@plt>:
  401680:	ff 25 aa 09 20 00    	jmp    *0x2009aa(%rip)        # 602030 <system@GLIBC_2.2.5>
  401686:	68 03 00 00 00       	push   $0x3
  40168b:	e9 b0 ff ff ff       	jmp    401640 <.plt>

0000000000401690 <printf@plt>:
  401690:	ff 25 a2 09 20 00    	jmp    *0x2009a2(%rip)        # 602038 <printf@GLIBC_2.2.5>
  401696:	68 04 00 00 00       	push   $0x4
  40169b:	e9 a0 ff ff ff       	jmp    401640 <.plt>

00000000004016a0 <memcpy@plt>:
  4016a0:	ff 25 9a 09 20 00    	jmp    *0x20099a(%rip)        # 602040 <memcpy@GLIBC_2.14>
  4016a6:	68 05 00 00 00       	push   $0x5
  4016ab:	e9 90 ff ff ff       	jmp    401640 <.plt>

00000000004016b0 <gets@plt>:
  4016b0:	ff 25 92 09 20 00    	jmp    *0x200992(%rip)        # 602048 <gets@GLIBC_2.2.5>
  4016b6:	68 06 00 00 00       	push   $0x6
  4016bb:	e9 80 ff ff ff       	jmp    401640 <.plt>

00000000004016c0 <fflush@plt>:
  4016c0:	ff 25 8a 09 20 00    	jmp    *0x20098a(%rip)        # 602050 <fflush@GLIBC_2.2.5>
  4016c6:	68 07 00 00 00       	push   $0x7
  4016cb:	e9 70 ff ff ff       	jmp    401640 <.plt>

00000000004016d0 <memmove@plt>:
  4016d0:	ff 25 82 09 20 00    	jmp    *0x200982(%rip)        # 602058 <memmove@GLIBC_2.2.5>
  4016d6:	68 08 00 00 00       	push   $0x8
  4016db:	e9 60 ff ff ff       	jmp    401640 <.plt>

00000000004016e0 <exit@plt>:
  4016e0:	ff 25 7a 09 20 00    	jmp    *0x20097a(%rip)        # 602060 <exit@GLIBC_2.2.5>
  4016e6:	68 09 00 00 00       	push   $0x9
  4016eb:	e9 50 ff ff ff       	jmp    401640 <.plt>

Disassembly of section .text:

0000000000401700 <_start>:
  401700:	31 ed                	xor    %ebp,%ebp
  401702:	49 89 d1             	mov    %rdx,%r9
  401705:	5e                   	pop    %rsi
  401706:	48 89 e2             	mov    %rsp,%rdx
  401709:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  40170d:	50                   	push   %rax
  40170e:	54                   	push   %rsp
  40170f:	49 c7 c0 40 1a 40 00 	mov    $0x401a40,%r8
  401716:	48 c7 c1 d0 19 40 00 	mov    $0x4019d0,%rcx
  40171d:	48 c7 c7 b4 19 40 00 	mov    $0x4019b4,%rdi
  401724:	ff 15 c6 08 20 00    	call   *0x2008c6(%rip)        # 601ff0 <__libc_start_main@GLIBC_2.2.5>
  40172a:	f4                   	hlt
  40172b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000401730 <_dl_relocate_static_pie>:
  401730:	f3 c3                	repz ret
  401732:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  401739:	00 00 00 
  40173c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401740 <deregister_tm_clones>:
  401740:	55                   	push   %rbp
  401741:	b8 78 20 60 00       	mov    $0x602078,%eax
  401746:	48 3d 78 20 60 00    	cmp    $0x602078,%rax
  40174c:	48 89 e5             	mov    %rsp,%rbp
  40174f:	74 17                	je     401768 <deregister_tm_clones+0x28>
  401751:	b8 00 00 00 00       	mov    $0x0,%eax
  401756:	48 85 c0             	test   %rax,%rax
  401759:	74 0d                	je     401768 <deregister_tm_clones+0x28>
  40175b:	5d                   	pop    %rbp
  40175c:	bf 78 20 60 00       	mov    $0x602078,%edi
  401761:	ff e0                	jmp    *%rax
  401763:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  401768:	5d                   	pop    %rbp
  401769:	c3                   	ret
  40176a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000401770 <register_tm_clones>:
  401770:	be 78 20 60 00       	mov    $0x602078,%esi
  401775:	55                   	push   %rbp
  401776:	48 81 ee 78 20 60 00 	sub    $0x602078,%rsi
  40177d:	48 89 e5             	mov    %rsp,%rbp
  401780:	48 c1 fe 03          	sar    $0x3,%rsi
  401784:	48 89 f0             	mov    %rsi,%rax
  401787:	48 c1 e8 3f          	shr    $0x3f,%rax
  40178b:	48 01 c6             	add    %rax,%rsi
  40178e:	48 d1 fe             	sar    $1,%rsi
  401791:	74 15                	je     4017a8 <register_tm_clones+0x38>
  401793:	b8 00 00 00 00       	mov    $0x0,%eax
  401798:	48 85 c0             	test   %rax,%rax
  40179b:	74 0b                	je     4017a8 <register_tm_clones+0x38>
  40179d:	5d                   	pop    %rbp
  40179e:	bf 78 20 60 00       	mov    $0x602078,%edi
  4017a3:	ff e0                	jmp    *%rax
  4017a5:	0f 1f 00             	nopl   (%rax)
  4017a8:	5d                   	pop    %rbp
  4017a9:	c3                   	ret
  4017aa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

00000000004017b0 <__do_global_dtors_aux>:
  4017b0:	80 3d d1 08 20 00 00 	cmpb   $0x0,0x2008d1(%rip)        # 602088 <completed.7698>
  4017b7:	75 17                	jne    4017d0 <__do_global_dtors_aux+0x20>
  4017b9:	55                   	push   %rbp
  4017ba:	48 89 e5             	mov    %rsp,%rbp
  4017bd:	e8 7e ff ff ff       	call   401740 <deregister_tm_clones>
  4017c2:	c6 05 bf 08 20 00 01 	movb   $0x1,0x2008bf(%rip)        # 602088 <completed.7698>
  4017c9:	5d                   	pop    %rbp
  4017ca:	c3                   	ret
  4017cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  4017d0:	f3 c3                	repz ret
  4017d2:	0f 1f 40 00          	nopl   0x0(%rax)
  4017d6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4017dd:	00 00 00 

00000000004017e0 <frame_dummy>:
  4017e0:	55                   	push   %rbp
  4017e1:	48 89 e5             	mov    %rsp,%rbp
  4017e4:	5d                   	pop    %rbp
  4017e5:	eb 89                	jmp    401770 <register_tm_clones>
  4017e7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4017ee:	00 00 00 
  4017f1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4017f8:	00 00 00 
  4017fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000401800 <pad_no_wrapper>:
	...

0000000000401868 <input>:
  401868:	55                   	push   %rbp
  401869:	48 89 e5             	mov    %rsp,%rbp
  40186c:	48 83 ec 10          	sub    $0x10,%rsp
  401870:	be 0f 00 00 00       	mov    $0xf,%esi
  401875:	bf 88 1a 40 00       	mov    $0x401a88,%edi
  40187a:	b8 00 00 00 00       	mov    $0x0,%eax
  40187f:	e8 0c fe ff ff       	call   401690 <printf@plt>
  401884:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  401888:	48 89 c7             	mov    %rax,%rdi
  40188b:	e8 20 fe ff ff       	call   4016b0 <gets@plt>
  401890:	48 85 c0             	test   %rax,%rax
  401893:	74 0b                	je     4018a0 <input+0x38>
  401895:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  401899:	0f b6 00             	movzbl (%rax),%eax
  40189c:	84 c0                	test   %al,%al
  40189e:	75 14                	jne    4018b4 <input+0x4c>
  4018a0:	bf 70 1a 40 00       	mov    $0x401a70,%edi
  4018a5:	e8 b6 fd ff ff       	call   401660 <puts@plt>
  4018aa:	bf 00 00 00 00       	mov    $0x0,%edi
  4018af:	e8 2c fe ff ff       	call   4016e0 <exit@plt>
  4018b4:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  4018b8:	48 89 c6             	mov    %rax,%rsi
  4018bb:	bf 90 20 60 00       	mov    $0x602090,%edi
  4018c0:	e8 8b fd ff ff       	call   401650 <strcpy@plt>
  4018c5:	90                   	nop
  4018c6:	c9                   	leave
  4018c7:	c3                   	ret

00000000004018c8 <eval>:
  4018c8:	55                   	push   %rbp
  4018c9:	48 89 e5             	mov    %rsp,%rbp
  4018cc:	48 83 ec 10          	sub    $0x10,%rsp
  4018d0:	bf 90 20 60 00       	mov    $0x602090,%edi
  4018d5:	e8 96 fd ff ff       	call   401670 <strlen@plt>
  4018da:	48 83 f8 0f          	cmp    $0xf,%rax
  4018de:	77 0c                	ja     4018ec <eval+0x24>
  4018e0:	bf 90 20 60 00       	mov    $0x602090,%edi
  4018e5:	e8 86 fd ff ff       	call   401670 <strlen@plt>
  4018ea:	eb 05                	jmp    4018f1 <eval+0x29>
  4018ec:	b8 0f 00 00 00       	mov    $0xf,%eax
  4018f1:	89 45 fc             	mov    %eax,-0x4(%rbp)
  4018f4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  4018f7:	83 c0 01             	add    $0x1,%eax
  4018fa:	48 98                	cltq
  4018fc:	b9 98 20 60 00       	mov    $0x602098,%ecx
  401901:	48 89 c2             	mov    %rax,%rdx
  401904:	be 90 20 60 00       	mov    $0x602090,%esi
  401909:	48 89 cf             	mov    %rcx,%rdi
  40190c:	e8 bf fd ff ff       	call   4016d0 <memmove@plt>
  401911:	ba 08 00 00 00       	mov    $0x8,%edx
  401916:	be 60 1a 40 00       	mov    $0x401a60,%esi
  40191b:	bf 90 20 60 00       	mov    $0x602090,%edi
  401920:	e8 7b fd ff ff       	call   4016a0 <memcpy@plt>
  401925:	8b 45 fc             	mov    -0x4(%rbp),%eax
  401928:	48 98                	cltq
  40192a:	48 83 c0 08          	add    $0x8,%rax
  40192e:	48 05 90 20 60 00    	add    $0x602090,%rax
  401934:	0f b7 15 2e 01 00 00 	movzwl 0x12e(%rip),%edx        # 401a69 <wrapper_back>
  40193b:	66 89 10             	mov    %dx,(%rax)
  40193e:	0f b6 15 26 01 00 00 	movzbl 0x126(%rip),%edx        # 401a6b <wrapper_back+0x2>
  401945:	88 50 02             	mov    %dl,0x2(%rax)
  401948:	be 90 20 60 00       	mov    $0x602090,%esi
  40194d:	bf b0 1a 40 00       	mov    $0x401ab0,%edi
  401952:	b8 00 00 00 00       	mov    $0x0,%eax
  401957:	e8 34 fd ff ff       	call   401690 <printf@plt>
  40195c:	bf 90 20 60 00       	mov    $0x602090,%edi
  401961:	e8 1a fd ff ff       	call   401680 <system@plt>
  401966:	48 8b 05 13 07 20 00 	mov    0x200713(%rip),%rax        # 602080 <stdout@GLIBC_2.2.5>
  40196d:	48 89 c7             	mov    %rax,%rdi
  401970:	e8 4b fd ff ff       	call   4016c0 <fflush@plt>
  401975:	90                   	nop
  401976:	c9                   	leave
  401977:	c3                   	ret

0000000000401978 <grade_eval>:
  401978:	55                   	push   %rbp
  401979:	48 89 e5             	mov    %rsp,%rbp
  40197c:	48 83 ec 10          	sub    $0x10,%rsp
  401980:	89 7d fc             	mov    %edi,-0x4(%rbp)
  401983:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  401987:	75 19                	jne    4019a2 <grade_eval+0x2a>
  401989:	b8 45 00 00 00       	mov    $0x45,%eax
  40198e:	2b 45 fc             	sub    -0x4(%rbp),%eax
  401991:	89 c6                	mov    %eax,%esi
  401993:	bf c0 1a 40 00       	mov    $0x401ac0,%edi
  401998:	b8 00 00 00 00       	mov    $0x0,%eax
  40199d:	e8 ee fc ff ff       	call   401690 <printf@plt>
  4019a2:	48 8b 05 d7 06 20 00 	mov    0x2006d7(%rip),%rax        # 602080 <stdout@GLIBC_2.2.5>
  4019a9:	48 89 c7             	mov    %rax,%rdi
  4019ac:	e8 0f fd ff ff       	call   4016c0 <fflush@plt>
  4019b1:	90                   	nop
  4019b2:	c9                   	leave
  4019b3:	c3                   	ret

00000000004019b4 <main>:
  4019b4:	55                   	push   %rbp
  4019b5:	48 89 e5             	mov    %rsp,%rbp
  4019b8:	b8 00 00 00 00       	mov    $0x0,%eax
  4019bd:	e8 a6 fe ff ff       	call   401868 <input>
  4019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  4019c7:	e8 fc fe ff ff       	call   4018c8 <eval>
  4019cc:	eb ea                	jmp    4019b8 <main+0x4>
  4019ce:	66 90                	xchg   %ax,%ax

00000000004019d0 <__libc_csu_init>:
  4019d0:	41 57                	push   %r15
  4019d2:	41 56                	push   %r14
  4019d4:	49 89 d7             	mov    %rdx,%r15
  4019d7:	41 55                	push   %r13
  4019d9:	41 54                	push   %r12
  4019db:	4c 8d 25 2e 04 20 00 	lea    0x20042e(%rip),%r12        # 601e10 <__frame_dummy_init_array_entry>
  4019e2:	55                   	push   %rbp
  4019e3:	48 8d 2d 2e 04 20 00 	lea    0x20042e(%rip),%rbp        # 601e18 <__do_global_dtors_aux_fini_array_entry>
  4019ea:	53                   	push   %rbx
  4019eb:	41 89 fd             	mov    %edi,%r13d
  4019ee:	49 89 f6             	mov    %rsi,%r14
  4019f1:	4c 29 e5             	sub    %r12,%rbp
  4019f4:	48 83 ec 08          	sub    $0x8,%rsp
  4019f8:	48 c1 fd 03          	sar    $0x3,%rbp
  4019fc:	e8 1f fc ff ff       	call   401620 <_init>
  401a01:	48 85 ed             	test   %rbp,%rbp
  401a04:	74 20                	je     401a26 <__libc_csu_init+0x56>
  401a06:	31 db                	xor    %ebx,%ebx
  401a08:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  401a0f:	00 
  401a10:	4c 89 fa             	mov    %r15,%rdx
  401a13:	4c 89 f6             	mov    %r14,%rsi
  401a16:	44 89 ef             	mov    %r13d,%edi
  401a19:	41 ff 14 dc          	call   *(%r12,%rbx,8)
  401a1d:	48 83 c3 01          	add    $0x1,%rbx
  401a21:	48 39 dd             	cmp    %rbx,%rbp
  401a24:	75 ea                	jne    401a10 <__libc_csu_init+0x40>
  401a26:	48 83 c4 08          	add    $0x8,%rsp
  401a2a:	5b                   	pop    %rbx
  401a2b:	5d                   	pop    %rbp
  401a2c:	41 5c                	pop    %r12
  401a2e:	41 5d                	pop    %r13
  401a30:	41 5e                	pop    %r14
  401a32:	41 5f                	pop    %r15
  401a34:	c3                   	ret
  401a35:	90                   	nop
  401a36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  401a3d:	00 00 00 

0000000000401a40 <__libc_csu_fini>:
  401a40:	f3 c3                	repz ret

Disassembly of section .fini:

0000000000401a44 <_fini>:
  401a44:	48 83 ec 08          	sub    $0x8,%rsp
  401a48:	48 83 c4 08          	add    $0x8,%rsp
  401a4c:	c3                   	ret
