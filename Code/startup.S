.globl _start
.globl _stack_top
.section .text.startup, "ax"
# Entry point
_start:
    # Set up the stack pointer
    lui sp,%hi(_stack_top)
    addi sp,sp,%lo(_stack_top)

    # Go to main
    jal main

    # Loop forever
_forever:
    j _forever

# Define a default exception handler to be overriden by the program
# The linker will make sure this function is at the proper address
.section .ehandler, "ax"
.globl Exception_Handler
_Exception_Handler:
    j Exception_Handler