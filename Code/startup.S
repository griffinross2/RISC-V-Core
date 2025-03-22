.globl _start
.globl _stack_top
.globl _svectors
.section .text.startup, "ax"
# Entry point
_start:
    # Set up the stack pointer
    lui sp,%hi(_stack_top)
    addi sp,sp,%lo(_stack_top)

    # Set the interrupt vector base address
    lui a0,%hi(_svectors)
    addi a0,a0,%lo(_svectors)
    csrw mtvec,a0

    # Set vectored interrupts and enable
    csrs mtvec,0x1
    csrs mstatus,0x8

    # Go to main
    jal main

    # Loop forever
_forever:
    j _forever

# Define the vector table
.section .text.vectors, "ax"
_vector_table:
    j Exception_Handler
