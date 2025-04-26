
[org 0x7c00]

mov ah,0x02 ; Set cursor position 
mov bh,0x00 ; page number (usually 0)
mov dh,row ; Y cordinate
mov dl,column; X cordinate
int 0x10

;Variable
row equ 10
column equ 10
times 510 - ($-$$) db 0
dw 0xaa55
