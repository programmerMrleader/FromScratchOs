


bits 32
section .multiboot
align 4
    dd 0x1BADB002          ; Magic number
    dd 0x00000003          ; Flags (align modules + memory map)
    dd -(0x1BADB002 + 0x00000003) ; Checksum



section .text
extern kernel_main
extern divide_error_handler
extern keyboard_handler
global _start
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
global isr0; interrupt service 
isr0:
	cli
	push byte 0
	push byte 0 
	jmp isr_common
global irq1
irq1:
	cli 
	push byte 0
	push byte 33
	jmp irq_common
isr_common:
	pusha 
	mov ax,ds
	push eax
	mov ax,0x10
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

	call divide_error_handler

	pop eax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	popa 
	add esp,8
	sti
	iret
irq_common:
	pusha
	mov ax,ds
	push eax
	mov ax,0x10
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

	call keyboard_handler

	pop eax 
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	popa 
	add esp,8
	sti
	iret 
section .bss
align 16
stack_bottom:
    resb 16384             ; 16KB stack
stack_top:
