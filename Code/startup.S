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

    # Initialize the sdata segment
    la a0, __sdata_start_load
    la a1, __sdata_end_load
    la a2, __sdata_start
    sdata_load_loop:
        bge a0, a1, sdata_load_done
        lw t0, 0(a0)
        sw t0, 0(a2)
        addi a0, a0, 4
        addi a2, a2, 4
        j sdata_load_loop
    sdata_load_done:

    # Initialize the data segment
    la a0, __data_start_load
    la a1, __data_end_load
    la a2, __data_start
    data_load_loop:
        bge a0, a1, data_load_done
        lw t0, 0(a0)
        sw t0, 0(a2)
        addi a0, a0, 4
        addi a2, a2, 4
        j data_load_loop
    data_load_done:

    # Zero-initialize the sbss segment
    la a0, __sbss_start
    la a1, __sbss_end
    sbss_zero_loop:
        bge a0, a1, sbss_zero_done
        sw zero, 0(a0)
        addi a0, a0, 4
        j sbss_zero_loop
    sbss_zero_done:

    # Zero-initialize the bss segment
    la a0, __bss_start
    la a1, __bss_end
    bss_zero_loop:
        bge a0, a1, bss_zero_done
        sw zero, 0(a0)
        addi a0, a0, 4
        j bss_zero_loop
    bss_zero_done:

    # Set the interrupt vector base address
    lui a0,%hi(_vector_table)
    addi a0,a0,%lo(_vector_table)
    csrw mtvec,a0

    # Set vectored interrupts and enable
    csrs mtvec,0x1
    csrs mstatus,0x8

    # Go to main
    call main

    # Break
    ebreak

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

