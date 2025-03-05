#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#Mergesort for benchmarking
#Optimized for 512 bit I$ 1024 bit D$
#Author Adam Hendrickson ahendri@purdue.edu

.text

_start:
  ori   x8, x0, 0xFFC
   ori   x2, x0, 0xFFC
   lui x3, 0xffff7  
  sub x2, x2, x3
  sub x8, x8, x3
  lui x3, 0x00007
  add x2, x2, x3
  add x8, x8, x3
   ori   x12, x0, data
   lw    x24, size(x0)
   ori   x6, x0, 1
   srl  x13,x24,x6
   or    x9, x0, x12
   or    x18, x0, x13
   jal   insertion_sort
  ori   x6, x0, 1
   srl  x5,x24,x6
   sub  x13, x24, x5
   ori   x6, x0, 2
   sll  x5,x5,x6
   ori   x12, x0, data
   add  x12, x12, x5
   or    x19, x0, x12
   or    x20, x0, x13
   jal   insertion_sort
  or    x12, x0, x9
   or    x13, x0, x18
   or    x14, x0, x19
   or    x15, x0, x20
   ori   x5, x0, sorted
   push  x5
   jal   merge
  addi x2, x2, 4
   ebreak



#void insertion_sort(int* $a0, int $a1)
# $a0 : pointer to data start
# $a1 : size of array
#--------------------------------------
insertion_sort:
  ori   x5, x0, 4
   ori   x7, x0, 2
   sll  x6,x13,x7
 is_outer:
  sltu  x4, x5, x6
   beq   x4, x0, is_end
   add  x31, x12, x5
   lw    x30, 0(x31)
 is_inner:
  beq   x31, x12, is_inner_end
   lw    x16, -4(x31)
   slt   x4, x30, x16
   beq   x4, x0, is_inner_end
   sw    x16, 0(x31)
   addi x31, x31, -4
   j     is_inner
is_inner_end:
  sw    x30, 0(x31)
   addi x5, x5, 4
   j     is_outer
is_end:
  jr    x1
 #--------------------------------------

#void merge(int* $a0, int $a1, int* $a2, int $a3, int* dst)
# $a0 : pointer to list 1
# $a1 : size of list 1
# $a2 : pointer to list 2
# $a3 : size of list 2
# dst [sp+4] : pointer to merged list location
#--------------------------------------
merge:
  lw    x5, 0(x2)
 m_1:
  bne   x13, x0, m_3
 m_2:
  bne   x15, x0, m_3
   j     m_end
m_3:
  beq   x15, x0, m_4
   beq   x13, x0, m_5
   lw    x6, 0(x12)
   lw    x7, 0(x14)
   slt   x4, x6, x7
   beq   x4, x0, m_3a
   sw    x6, 0(x5)
   addi x5, x5, 4
   addi x12, x12, 4
   addi x13, x13, -1
   j     m_1
m_3a:
  sw    x7, 0(x5)
   addi x5, x5, 4
   addi x14, x14, 4
   addi x15, x15, -1
   j     m_1
m_4:  #left copy
  lw    x6, 0(x12)
   sw    x6, 0(x5)
   addi x5, x5, 4
   addi x13, x13, -1
   addi x12, x12, 4
   beq   x13, x0, m_end
   j     m_4
m_5:  # right copy
  lw    x7, 0(x14)
   sw    x7, 0(x5)
   addi x5, x5, 4
   addi x15, x15, -1
   addi x14, x14, 4
   beq   x15, x0, m_end
   j     m_5
m_end:
  jr    x1
 #--------------------------------------


org 0x300
size:
cfw 64
data:
cfw 90
cfw 81
cfw 51
cfw 25
cfw 80
cfw 41
cfw 22
cfw 21
cfw 12
cfw 62
cfw 75
cfw 71
cfw 83
cfw 81
cfw 77
cfw 22
cfw 11
cfw 29
cfw 7
cfw 33
cfw 99
cfw 27
cfw 100
cfw 66
cfw 61
cfw 32
cfw 1
cfw 54
cfw 4
cfw 61
cfw 56
cfw 3
cfw 48
cfw 8
cfw 66
cfw 100
cfw 15
cfw 92
cfw 65
cfw 32
cfw 9
cfw 47
cfw 89
cfw 17
cfw 7
cfw 35
cfw 68
cfw 32
cfw 10
cfw 7
cfw 23
cfw 92
cfw 91
cfw 40
cfw 26
cfw 8
cfw 36
cfw 38
cfw 8
cfw 38
cfw 16
cfw 50
cfw 7
cfw 67

org 0x500
sorted:
