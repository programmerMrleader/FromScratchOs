

[org 0x7c00]
start:
    cli
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00
    sti
    ; Set ES:BX to memory where we want to load bootloader 
    mov bx,0x8000 ; Load ES:BX
    mov dh,0x00 ; Head - 0
    mov dl,0x00 ; Dirve 0 (Floppy or hard drive)
    mov ch,0x00 ; Cylinder 0
    mov cl,2

    mov ah,0x02
    mov al,1
    int 0x13
    jc disk_error
    mov si,0x8000 ; set si to start of loaded data
print_loop:
    lodsb
    cmp al,0
    je hang
    mov ah,0x0e
    int 0x10
    jmp print_loop

disk_error:
    mov si,error_msg
    call print_error
print_error:
    lodsb
    or al,al
    jz hang
    mov ah,0x0e
    int 0x10
    jmp disk_error
hang:
    hlt
    jmp hang
 
error_msg db 'Disk Error' , 0
times 510 - ($-$$) db 0
dw 0xaa55
