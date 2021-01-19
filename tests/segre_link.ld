OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x000;
    .text : { *(.text) }
    . = ALIGN(0xA000);
    .data : { *(.data) }
}

