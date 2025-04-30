section .multiboot
align 4
    dd 0x1BADB002          ; Magic number
    dd 0x00000003          ; Flags (align modules + memory map)
    dd -(0x1BADB002 + 0x03) ; Checksum

section .bss
align 16
stack_bottom:
    resb 16384             ; 16KB stack
stack_top:

section .text
global _start
extern kernel_main

_start:
    ; Set up stack
    mov esp, stack_top

    ; Push Multiboot info
    push ebx               ; Multiboot info structure
    push eax               ; Magic number

    call kernel_main       ; Call C kernel

    cli
.hang:
    hlt
    jmp .hang
