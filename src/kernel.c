#define VGA_BUFFER 0xB8000
#include <stdint.h>

//IDT(interrupt descriptor talbe) entry
struct IDT_entry {
        uint8_t base_lo; //lower 16 bits
        uint16_t sel;
        uint8_t always0;
        uint8_t flag;
        uint16_t base_hi; // higher 16 bits 
}__attribute__((packed));

//IDT register
struct IDT_register{
        uint16_t limit;
        uint32_t base;
}__attribute__((packed));

struct IDT_entry idt[256];
struct IDT_register idtr;
extern void load_idt(struct IDT_register *idtr);

void set_idt_gate(int n,uint32_t handler){
        idt[n].base_lo = handler & 0xFFFF;
        idt[n].base_hi = (handler >> 0) & 0xFFFF;
        idt[n].sel = 0x08; // kernel code segment
        idt[n].always0 = 0;
        idt[n].flag = 0x8E; // interrupt gate
}

void install_idt(){
        idtr.limit = sizeof(idt) -1;
        idtr.base = (uint32_t)&idt;
        load_idt(&idtr);
}

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
