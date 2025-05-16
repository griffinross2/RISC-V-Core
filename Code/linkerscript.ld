/* linker.ld */
/* By professor ChatGPT */
OUTPUT_ARCH(riscv)
ENTRY(_start) /* where execution begins */

MEMORY
{
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
    RAM (rwx)  : ORIGIN = 0x10000000, LENGTH = 256M
    FLASH (rx) : ORIGIN = 0x00800000, LENGTH = 8M
}

PROVIDE(_heap_start = _end);
PROVIDE(_heap_end = ORIGIN(RAM) + LENGTH(RAM));

SECTIONS
{
    /* Bootloader */
    .boot :
    {
        . = ALIGN(4);
        *(.init .init.*)
    } > ROM

    /* Code and read-only data */
    .text :
    {
        . = ALIGN(4);
        __text_start = .;
        *(.text .text.*)
        *(.rodata .rodata.*)
        KEEP(*(.ctors))
        KEEP(*(.dtors))
        __text_end = .;
    } > FLASH

    /* Small initialized data (for gp-relative access) */
    .sdata :
    {
        . = ALIGN(4);
        __sdata_start = .;
        *(.sdata .sdata.*)
        __sdata_end = .;
    } > RAM AT > FLASH

    /* Small uninitialized data (zero at boot) */
    .sbss (NOLOAD) :
    {
        . = ALIGN(4);
        __sbss_start = .;
        *(.sbss .sbss.*)
        __sbss_end = .;
    } > RAM

    /* Normal initialized global variables */
    .data :
    {
        . = ALIGN(4);
        __data_start = .;
        *(.data .data.*)
        __data_end = .;
    } > RAM AT > FLASH

    /* Normal uninitialized global variables (zero at boot) */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss .bss.*)
        __bss_end = .;
    } > RAM

    /* Stack */
    .stack (NOLOAD) :
    {
        . = ALIGN(4);
        __stack_start = .;
        . = . + 4K;
        __stack_end = .;
    } > RAM

    _end = .;

    __text_start_load = LOADADDR(.text);
    __sdata_start_load = LOADADDR(.sdata);
    __data_start_load = LOADADDR(.data);
    __text_end_load = LOADADDR(.text) + SIZEOF(.text);
    __sdata_end_load = LOADADDR(.sdata) + SIZEOF(.sdata);
    __data_end_load = LOADADDR(.data) + SIZEOF(.data);
}

/* Define runtime symbols */
PROVIDE(__stack = ORIGIN(RAM) + LENGTH(RAM));
PROVIDE(_stack = __stack);
PROVIDE(__global_pointer$ = (__sdata_start + __sbss_end) / 2);