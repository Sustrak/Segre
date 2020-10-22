OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x0;
    .text : { *(.text) }
    . = ALIGN(0xA000);
    .data : { *(.data) }
}

