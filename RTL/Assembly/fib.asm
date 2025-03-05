#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------
# Test with a fibonacci sequence
#--------------------------------------
  .text

_start:

  ori   x10, x10, start
   ori   x4, x4, 1
   ori   x5, x5, 4
   lui   x28, 0xFFFFF
   ori   x14, x14, 0xF00
   sub x14, x14, x28
   lw    x16, 0(x14)
 
loop:
  lw    x11, 0 (x10)
   lw    x12, 4 (x10)
   add  x13, x11, x12
   sw    x13, 8 (x10)
   add  x10, x10, x5
   sub  x16, x16, x4
   bne   x16, x0, loop
 end:
  ebreak

  org 0x80

start:
  cfw 0
  cfw 1

#uncomment to work with the simulator (sim)
# comment to use mmio

  org 0x0F00
  cfw 22
