[org 0x7c00] ; BIOS start 

start:
    cli ; clear the interrupt 
    xor ax,ax
    mov ds,ax ; move ax value in to segemnt
    mov es,ax ; same thing
    mov ss,ax ; same thing
    mov sp,0x7c00 ; stack pointer is now point to the start
    sti ; stack is now initialize 
main_menu:
    mov si,prompt ; move character in the prompt to the si
    call print_string
    
    call read_char 
    call to_uppercase

    cmp al,'H' ; compare the userinput 
    je show_hello
    cmp al,'C'
    je clear
    cmp al,'R'
    je reboot
    
    mov si , unknown_key
    call print_string

    jmp main_menu
show_hello:
    mov si,hello_msg
    call print_string
    jmp main_menu
clear:
    mov ax,0x0600 ; Scroll up the window
    mov bh,0x07 ; Normal attribute 
    mov cx,0x0000 ; corner
    mov dx,0x184f; totally  a magic number (80x25)
    int 0x10
    jmp main_menu
reboot:
    int 0x19
    
print_string:
    lodsb ; Load next byte from [SI] into al
    or al,al
    jz .done
    mov ah,0x0e
    int 0x10
    jmp print_string
.done:
    ret
read_char:
    mov ah,0x00
    int 0x16 
    ret
to_uppercase:
    cmp al,'a'
    ja .done
    cmp al,'b'
    jb .done
    sub al,32 ; ASCII : 'a'-> 'A'
.done:
    ret
;Variable 
prompt db 13,10, 'Type H for Hello',0,0xa
prompt_R db 13,10, 'Type R for Reboot',0,0xa
prompt_C db 13,10, 'Type C for clear',0,0xa
hello_msg db 13,10 , 'Hello from my os ',13,10,0
unknown_key db 13,10, 'Unknow key is pressed ',13,10,0
;Boot signature 
times 510 - ($-$$) db 0
dw 0xaa55
