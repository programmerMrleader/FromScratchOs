


db "Hello from disk",0xa
db "Hello from floppy",0xa
times 512 - ($ -$$) db 0
