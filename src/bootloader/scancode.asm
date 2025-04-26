[org 0x7c00]
print:
    mov ah,0x00
    int 0x16
    mov al,ah
    mov ah,0x0e
    int 0x10
    jmp print
times 510 - ($ - $$ ) db 0
dw 0xaa55
