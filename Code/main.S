
main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00010137          	lui	sp,0x10
   4:	00010113          	mv	sp,sp
   8:	008000ef          	jal	10 <main>

0000000c <_forever>:
   c:	0000006f          	j	c <_forever>

00000010 <main>:
  10:	fe010113          	addi	sp,sp,-32 # ffe0 <_stack_bottom+0x3e0>
  14:	00112e23          	sw	ra,28(sp)
  18:	00812c23          	sw	s0,24(sp)
  1c:	02010413          	addi	s0,sp,32
  20:	00200793          	li	a5,2
  24:	fef42623          	sw	a5,-20(s0)
  28:	00300793          	li	a5,3
  2c:	fef42423          	sw	a5,-24(s0)
  30:	fec42703          	lw	a4,-20(s0)
  34:	fe842783          	lw	a5,-24(s0)
  38:	00f707b3          	add	a5,a4,a5
  3c:	fef42223          	sw	a5,-28(s0)
  40:	000047b7          	lui	a5,0x4
  44:	fe442703          	lw	a4,-28(s0)
  48:	00e7a023          	sw	a4,0(a5) # 4000 <Exception_Handler+0x3f9c>
  4c:	00100073          	ebreak
  50:	00000013          	nop
  54:	01c12083          	lw	ra,28(sp)
  58:	01812403          	lw	s0,24(sp)
  5c:	02010113          	addi	sp,sp,32
  60:	00008067          	ret

00000064 <Exception_Handler>:
  64:	ff010113          	addi	sp,sp,-16
  68:	00112623          	sw	ra,12(sp)
  6c:	00812423          	sw	s0,8(sp)
  70:	01010413          	addi	s0,sp,16
  74:	0000006f          	j	74 <Exception_Handler+0x10>

Disassembly of section .ehandler:

00008000 <_Exception_Handler>:
    8000:	864f806f          	j	64 <Exception_Handler>

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	.insn	4, 0x3a434347
   4:	2820                	.insn	2, 0x2820
   6:	5078                	.insn	2, 0x5078
   8:	6361                	.insn	2, 0x6361
   a:	4e47206b          	.insn	4, 0x4e47206b
   e:	2055                	.insn	2, 0x2055
  10:	4952                	.insn	2, 0x4952
  12:	562d4353          	.insn	4, 0x562d4353
  16:	4520                	.insn	2, 0x4520
  18:	626d                	.insn	2, 0x626d
  1a:	6465                	.insn	2, 0x6465
  1c:	6564                	.insn	2, 0x6564
  1e:	2064                	.insn	2, 0x2064
  20:	20434347          	.insn	4, 0x20434347
  24:	3878                	.insn	2, 0x3878
  26:	5f36                	.insn	2, 0x5f36
  28:	3436                	.insn	2, 0x3436
  2a:	2029                	.insn	2, 0x2029
  2c:	3431                	.insn	2, 0x3431
  2e:	322e                	.insn	2, 0x322e
  30:	302e                	.insn	2, 0x302e
	...

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	2941                	.insn	2, 0x2941
   2:	0000                	.insn	2, 0x
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <main+0x4>
   c:	001f 0000 1004      	.insn	6, 0x10040000001f
  12:	7205                	.insn	2, 0x7205
  14:	3376                	.insn	2, 0x3376
  16:	6932                	.insn	2, 0x6932
  18:	7032                	.insn	2, 0x7032
  1a:	5f31                	.insn	2, 0x5f31
  1c:	326d                	.insn	2, 0x326d
  1e:	3070                	.insn	2, 0x3070
  20:	7a5f 6d6d 6c75      	.insn	6, 0x6c756d6d7a5f
  26:	7031                	.insn	2, 0x7031
  28:	0030                	.insn	2, 0x0030
