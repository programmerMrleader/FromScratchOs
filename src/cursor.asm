
[org 0x7c00]

start:
    cli ; clear the interrupt 
    xor ax,ax ; ax is now zero
    mov cs,ax
    mov ss,ax
    mov es,ax
    mov ds,ax
    mov si,0x7c00 ; stack is now below the bootloader
    sti    
main:  
    mov ah,0x00
    int 0x16
    cmp al,'s'
    je down
    cmp al,'d'
    je right
    cmp al,'a'
    je left
    cmp al,'w'
    je up
    mov si,error_msg
    call error
down:
    mov al,[row]
    inc al
    mov [row],al
    jmp cursor
right:
    mov al,[column]
    inc al
    mov [column],al
    jmp cursor
left:
    mov al,[column]
    dec al
    mov [column],al
    jmp cursor
up:
    mov al,[row]
    dec al
    mov [row],al
    jmp cursor
cursor:
    mov ah,0x02 
    mov bh,0x00
    mov dh,[row] ; Y cordinate
    mov dl,[column]; X cordinate
    int 0x10
    jmp main
error:
    lodsb
    or al,al
    jz .done
    mov ah,0x0e
    int 0x10
    jmp error
.done:
    ret
;Variable
row: db 0
column: db 0
error_msg db "Unknown command" , 0 

times 510 - ($-$$) db 0
dw 0xaa55
