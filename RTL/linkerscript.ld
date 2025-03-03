
SECTIONS
{
. = 0x00000;
.text ALIGN(4) : { *(.text) }
.data ALIGN(4) : { *(.data) }
.bss ALIGN(4) : { *(.bss) }
}