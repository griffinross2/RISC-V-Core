#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------
# Test a search algorithm
#--------------------------------------
  .text

_start:
  ori   x2, x0, 0x80
 start:
  ori   x4, x0, 0x01
   ori   x10, x0, 0x04
 
  sw    x0, 0(x2)            # set result to 0
   lw    x11, 4(x2)            # load search variable into x11
   lw    x12, 8(x2)            # load search length into x12
   addi x13, x2, 12           # search pointer is in x13
 
loop:
  lw    x14, 0(x13)             # load element at pointer x13
   sub  x15, x14, x11            # compare loaded element with search var
   beq   x15, x0, found      # if matches, go to found
   add  x13, x13, x10            # increment pointer
   sub  x12, x12, x4            # subutract search length
   beq   x12, x0, notfound   # if end of list, go to not found
   beq   x0, x0, loop       # do loop again
 found:
  sw    x13, 0(x2)            # store into 0x80
 notfound:
  ebreak


  org 0x80
item_position:
  cfw 0                       # should be found at 0x0124
search_item:
  cfw 0x5c6f
list_length:
  cfw 100
search_list:
  cfw 0x087d
  cfw 0x5fcb
  cfw 0xa41a
  cfw 0x4109
  cfw 0x4522
  cfw 0x700f
  cfw 0x766d
  cfw 0x6f60
  cfw 0x8a5e
  cfw 0x9580
  cfw 0x70a3
  cfw 0xaea9
  cfw 0x711a
  cfw 0x6f81
  cfw 0x8f9a
  cfw 0x2584
  cfw 0xa599
  cfw 0x4015
  cfw 0xce81
  cfw 0xf55b
  cfw 0x399e
  cfw 0xa23f
  cfw 0x3588
  cfw 0x33ac
  cfw 0xbce7
  cfw 0x2a6b
  cfw 0x9fa1
  cfw 0xc94b
  cfw 0xc65b
  cfw 0x0068
  cfw 0xf499
  cfw 0x5f71
  cfw 0xd06f
  cfw 0x14df
  cfw 0x1165
  cfw 0xf88d
  cfw 0x4ba4
  cfw 0x2e74
  cfw 0x5c6f
  cfw 0xd11e
  cfw 0x9222
  cfw 0xacdb
  cfw 0x1038
  cfw 0xab17
  cfw 0xf7ce
  cfw 0x8a9e
  cfw 0x9aa3
  cfw 0xb495
  cfw 0x8a5e
  cfw 0xd859
  cfw 0x0bac
  cfw 0xd0db
  cfw 0x3552
  cfw 0xa6b0
  cfw 0x727f
  cfw 0x28e4
  cfw 0xe5cf
  cfw 0x163c
  cfw 0x3411
  cfw 0x8f07
  cfw 0xfab7
  cfw 0x0f34
  cfw 0xdabf
  cfw 0x6f6f
  cfw 0xc598
  cfw 0xf496
  cfw 0x9a9a
  cfw 0xbd6a
  cfw 0x2136
  cfw 0x810a
  cfw 0xca55
  cfw 0x8bce
  cfw 0x2ac4
  cfw 0xddce
  cfw 0xdd06
  cfw 0xc4fc
  cfw 0xfb2f
  cfw 0xee5f
  cfw 0xfd30
  cfw 0xc540
  cfw 0xd5f1
  cfw 0xbdad
  cfw 0x45c3
  cfw 0x708a
  cfw 0xa359
  cfw 0xf40d
  cfw 0xba06
  cfw 0xbace
  cfw 0xb447
  cfw 0x3f48
  cfw 0x899e
  cfw 0x8084
  cfw 0xbdb9
  cfw 0xa05a
  cfw 0xe225
  cfw 0xfb0c
  cfw 0xb2b2
  cfw 0xa4db
  cfw 0x8bf9
  cfw 0x12f7
