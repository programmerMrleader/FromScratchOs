CC = i686-elf-gcc
ASM = nasm
CFLAGS = -ffreestanding -nostdlib -Wall -Wextra -masm=intel
LDFLAGS = -Wl,--oformat=elf32-i386 -T linker.ld -nostdlib

all: kernel.iso

kernel.elf: boot.o kernel.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

boot.o: boot.asm
	$(ASM) -f elf32 $< -o $@

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.iso: kernel.elf
	mkdir -p isodir/boot/grub
	cp kernel.elf isodir/boot/
	echo 'menuentry "My OS" { multiboot /boot/kernel.elf }' > isodir/boot/grub/grub.cfg
	grub-mkrescue -o $@ isodir

run: kernel.iso
	qemu-system-x86_64 -cdrom kernel.iso

clean:
	rm -rf *.o *.elf *.iso isodir
