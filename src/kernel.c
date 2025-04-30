#define VGA_BUFFER 0xB8000

void kernel_main(unsigned int magic, unsigned int* mb_info) {
    // Check Multiboot magic
    if(magic != 0x2BADB002) return;

    // VGA text buffer
    volatile char* vga = (volatile char*)VGA_BUFFER;
    
    // Print message
    const char* str = "Hello Multiboot!";
    for(int i = 0; str[i]; i++) {
        vga[i*2] = str[i];
        vga[i*2+1] = 0x0F; // White on black
    }

    while(1);
}
