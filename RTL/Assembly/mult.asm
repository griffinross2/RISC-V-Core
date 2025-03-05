# Lab 2 Multiply Subroutine in RISC-V Assembly
.text

_start:
# Setup data
    li      sp,    0xFFFC         # Initial Stack pointer
    li      x5,     5
    push    x5
    li      x5,     4
    push    x5
    li      x5,     3
    push    x5


multiply:
    # Setup
    pop     x5                      # Load first operand
    pop     x6                      # Load second operand
    addi    x7,     zero,  0       # Zero product register
    # Zero multiplier
    beq     x6,     zero,  exit    # Branch to the end
    # Loop
loop:
    add     x7,     x7,     x5      # Add multiplicand to product
    addi    x6,     x6,     -1      # Decrement multiplier
    bne     x6,     zero,  loop    # Loop
exit:
    push    x7                      # Push result
    ebreak
