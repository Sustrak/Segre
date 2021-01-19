OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x8000;
    .text : { *(.text) }
    . = ALIGN(0x12000);
    .data : { *(.data) }
}

