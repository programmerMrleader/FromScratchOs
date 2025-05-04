#include<stdint.h>
#include "port.h"
#define VGA_BUFFER 0xB8000

#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64
#define PIC1_CMD_PORT 0x20
#define PIC1_DATA_PORT 0x21
void print_char(char *c);
struct IDTEntry {
	uint16_t offset_low;
	uint16_t selector;
	uint8_t zero;
	uint8_t flags;
	uint16_t offset_high;
	
}__attribute__((packed));

struct IDTRegister {
	uint16_t limit;
	uint32_t base;
}__attribute__((packed));
extern void divide_error_handler(void);
extern void keyboard_handler(void);
extern void isr0(void);
extern void irq1(void);
struct IDTEntry idt[256];
struct IDTRegister idtr;
void idt_set_gate(int n,uint32_t handler,uint16_t sel,uint8_t flags){
	idt[n].offset_low = handler & 0xFFFF;
	idt[n].selector = sel;
	idt[n].zero = 0;
	idt[n].flags = flags;
	idt[n].offset_high = (handler >> 16) & 0xFFFF;
}
void idt_init(){
	idtr.limit = (sizeof(struct IDTEntry) * 256) -1;
	idtr.base = (uint32_t)&idt;
	idt_set_gate(0,(uint32_t)isr0,0x08,0x8E);
	idt_set_gate(33,(uint32_t)irq1,0x08,0x8E);

	__asm__ volatile("lidt %0" : : "m"(idtr));
	
}
void divide_error_handler(){
	print_char("Divide error");
	__asm__ volatile("cli;hlt");
}
#define ESC 27 // Define ESC if not already available
static const char scancode_map[128] = { // Only map relevant key presses (codes < 0x80)
      0,ESC, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b', // 0x00 - 0x0E
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',      // 0x0F - 0x1C (Enter)
       0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',          // 0x1D - 0x29 (Left Ctrl)
       0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',    0,        // 0x2A - 0x36 (Left Shift, Backslash, Z.. / , Right Shift)
       '*', // 0x37 (Keypad *)
       0,  // 0x38 (Left Alt)
     ' ',  // 0x39 (Space)
       0,  // 0x3A (Caps Lock)
    // --- F Keys F1-F10 (optional, map to 0 or special codes) ---
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,                         // 0x3B - 0x44 (F1-F10)
    // --- Lock Keys ---
       0,   0,                                                                  // 0x45 (Num Lock), 0x46 (Scroll Lock)
    // --- Keypad ---
     '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.',         // 0x47 - 0x53 (Keypad 7..9,-,4..6,+,1..3,0,.)
    // --- Others ---
       0,   0,   0,   0,   0,                                                  // 0x54 - 0x58 (F11, F12 unused/unmapped)
    // Add more mappings up to 0x7F if needed
};

void print_keycode(char c) {
    static int cursor_pos = 0; // Tracks screen position (char offset)
    char *video_memory = (char *)0xB8000; // VGA text mode memory
    const int WIDTH = 80;
    const int HEIGHT = 25;
    const int SCREEN_SIZE = WIDTH * HEIGHT;

    if (c == '\n') { // Handle newline
        cursor_pos = (cursor_pos / WIDTH + 1) * WIDTH;
    } else if (c == '\b') { // Handle basic backspace (optional)
        if (cursor_pos > 0) {
            cursor_pos--;
            video_memory[cursor_pos * 2] = ' '; // Erase char
            video_memory[cursor_pos * 2 + 1] = 0x0F; // White on black attribute
        }
    } else { // Handle regular character
        if (cursor_pos >= SCREEN_SIZE) { // Simple wrap-around if screen full
             cursor_pos = 0;
             // Add scrolling logic here if needed later
        }
        video_memory[cursor_pos * 2] = c;
        video_memory[cursor_pos * 2 + 1] = 0x0F; // White on black attribute
        cursor_pos++;
    }

    // Wrap cursor if it went off screen from newline or typing
    if (cursor_pos >= SCREEN_SIZE) {
         cursor_pos = 0; // Simple wrap-around
         // Add scrolling logic here if needed later
    }

    // Update hardware cursor (optional, requires more port I/O)
}
void keyboard_handler(){
	static uint8_t extended = 0;
	uint8_t scancode;
	scancode = inb(KEYBOARD_DATA_PORT);
	
	    // Handle extended scancodes (e.g., arrow keys, right ctrl/alt)
	    if (scancode == 0xE0) {
	        extended = 1;
	        // Don't send EOI yet, wait for the second byte
	    } else {
	        // Handle key release (scancode bit 7 is set)
	        if (scancode & 0x80) {
	            // Key released - We don't do anything on release for now
	            // If you were tracking shift/ctrl state, you'd update it here.
	            // Make sure to clear extended flag if this was an extended key release
	             if (extended) extended = 0;
	        }
	        // Handle key press (scancode bit 7 is clear)
	        else {
	            if (extended) {
	                // Handle extended key presses here (e.g., Arrow keys)
	                // Example: if (scancode == 0x48) print_keycode('^'); // Up Arrow
	                extended = 0; // Consume the extended flag
	            } else {
	                // Normal key press - check bounds before accessing map
	                if (scancode < sizeof(scancode_map)) { // *** FIX: Bounds check ***
	                    char c = scancode_map[scancode];
	                    if (c != 0) { // Check if it's a printable/mapped character
	                        print_keycode(c);
	                    }
	                }
	                // else: Scancode is out of range of our map, ignore it.
	            }
			}
	}
	outb(PIC1_CMD_PORT,0x20);
}
void pic_remap(){
	outb(PIC1_CMD_PORT,0x11);
	outb(0xA0,0x11);

	outb(PIC1_DATA_PORT,0x20);
	outb(0xA1,0x28);

	outb(PIC1_DATA_PORT,0x04);
	outb(0xA1,0x02);

	outb(PIC1_DATA_PORT,0x01);
	outb(0xA1,0x01);

	outb(PIC1_DATA_PORT,0xFD);
	outb(0xA1,0xFF);
	
}
void keyboard_init(){
	while(inb(KEYBOARD_STATUS_PORT) & 0x02);
	outb(KEYBOARD_STATUS_PORT,0xAD);

	while(inb(KEYBOARD_STATUS_PORT) & 0x02);
	outb(KEYBOARD_STATUS_PORT,0xA7);

	while(inb(KEYBOARD_STATUS_PORT) & 0x01){ inb(KEYBOARD_DATA_PORT); }

	while(inb(KEYBOARD_STATUS_PORT)&0x02);
	outb(KEYBOARD_STATUS_PORT,0x60);

	while(inb(KEYBOARD_STATUS_PORT) & 0x02);
	outb(KEYBOARD_DATA_PORT,0x45);

	while(inb(KEYBOARD_STATUS_PORT) & 0x02);
	outb(KEYBOARD_STATUS_PORT,0xAE);
	
}
void print_char(char *c){
	char *video_memory = (char*)VGA_BUFFER;
	static int i =0;
	while(c[i] != '\0'){
		video_memory[i*2] = c[i];
		video_memory[i*2+1] = 0x0F;
		i++;
	}
}
void kernel_main() {
	pic_remap();
	idt_init();
	keyboard_init();

	print_char("Key pressed");
    while(1);
}
