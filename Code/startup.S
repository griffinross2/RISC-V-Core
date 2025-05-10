.globl _start
.globl _stack
# Entry point
.section .init
_start:
    # Set the stack pointer
    la sp, __stack

    # Set the global pointer
    .option push
	.option norelax
	la gp, __global_pointer$
	.option pop

    # Set the interrupt vector base address
    lui a0,%hi(_vector_table)
    addi a0,a0,%lo(_vector_table)
    csrw mtvec,a0

    # Set vectored interrupts and enable
    csrs mtvec,0x1
    csrs mstatus,0x8

    # Go to main
    call main

    # Loop forever
_forever:
    j _forever

# Define the vector table
.section .text.vectors, "ax"
_vector_table:
    j Exception_Handler             # 0 - Exception
    j Unknown_Interrupt_Handler     # 1 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 2 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 3 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 4 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 5 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 6 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 7 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 8 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 9 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 10 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 11 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 12 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 13 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 14 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 15 - Unimplemented Interrupt
    j UART_RXI_Handler              # 16 - UART RX Interrupt
    j Unknown_Interrupt_Handler     # 17 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 18 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 19 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 20 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 21 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 22 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 23 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 24 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 25 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 26 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 27 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 28 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 29 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 30 - Unimplemented Interrupt
    j Unknown_Interrupt_Handler     # 31 - Unimplemented Interrupt

