[org 0x7c00] 
mov ah,0x0e ; teletype mode
mov al,'A' ; A is in the al now
int 0x10 ; interrupt is called 


cli ; clear the interrupt 
xor ax,ax; some opertaion

mov ss,ax 
mov sp , 0x7c00 ; 0x7c00 is the stack pointer now

sti; Enable the interrupt

times 510 - ($ - $$ ) db 0 
dw 0xAA55 
