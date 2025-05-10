/* linker.ld */
/* By professor ChatGPT */
OUTPUT_ARCH(riscv)
ENTRY(_start) /* where execution begins */

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 128K
}

PROVIDE(_heap_start = _end);
PROVIDE(_heap_end = ORIGIN(RAM) + LENGTH(RAM));

SECTIONS
{
    /* Code and read-only data */
    .text :
    {
        *(.init)
        *(.text .text.*)
        *(.rodata .rodata.*)
        KEEP(*(.ctors))
        KEEP(*(.dtors))
    } > RAM

    /* Small initialized data (for gp-relative access) */
    .sdata :
    {
        __sdata_start = .;
        *(.sdata .sdata.*)
        __sdata_end = .;
    } > RAM

    /* Small uninitialized data (zero at boot) */
    .sbss (NOLOAD) :
    {
        __sbss_start = .;
        *(.sbss .sbss.*)
        __sbss_end = .;
    } > RAM

    /* Normal initialized global variables */
    .data :
    {
        __data_start = .;
        *(.data .data.*)
        __data_end = .;
    } > RAM

    /* Normal uninitialized global variables (zero at boot) */
    .bss (NOLOAD) :
    {
        __bss_start = .;
        *(.bss .bss.*)
        __bss_end = .;
    } > RAM

    /* Stack */
    .stack (NOLOAD) :
    {
        __stack_start = .;
        . = . + 4K;
        __stack_end = .;
    } > RAM

    _end = .;
}

/* Define runtime symbols */
PROVIDE(__stack = ORIGIN(RAM) + LENGTH(RAM));
PROVIDE(_stack = __stack);
PROVIDE(__global_pointer$ = (__sdata_start + __sbss_end) / 2);