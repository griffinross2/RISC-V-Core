ENTRY(_start)

MEMORY {
    RAM (rwx)   : ORIGIN = 0x0, LENGTH = 0x10000
}

SECTIONS
{
    .text : {
        ALIGN(4) : { *(.text) }
    } > RAM
}