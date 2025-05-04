ENTRY(_start)

/* Force absolute .multiboot section */
SECTIONS {
    . = 1M;

    .multiboot 0x100000 : {
        *(.multiboot)
    } : text

    .text : ALIGN(4K) {
        *(.text*)
    }

    .rodata : ALIGN(4K) {
        *(.rodata*)
    }

    .data : ALIGN(4K) {
        *(.data*)
    }

    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss*)
    }
}

PHDRS {
    headers PT_PHDR PHDRS ;
    text PT_LOAD FILEHDR PHDRS ;
}
