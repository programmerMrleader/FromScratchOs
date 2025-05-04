# Makefile for Simple Kernel

# Tools
CC := i686-elf-gcc
AS := nasm
LD := i686-elf-ld
QEMU := qemu-system-i386

# Directories
BUILD_DIR := build
SRC_DIR := src

# Source files
ASM_SOURCES := $(SRC_DIR)/boot.asm
C_SOURCES := $(SRC_DIR)/kernel.c

# Object files
ASM_OBJECTS := $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

# Flags
ASFLAGS := -f elf32
CFLAGS := -ffreestanding -nostdlib -Wall -Wextra -O2
LDFLAGS := -T $(SRC_DIR)/linker.ld -m elf_i386

# Targets
all: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: $(ASM_OBJECTS) $(C_OBJECTS)
	@echo "Linking kernel..."
	@$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@echo "Assembling $<..."
	@mkdir -p $(@D)
	@$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<..."
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

run: $(BUILD_DIR)/kernel.bin
	@echo "Starting QEMU..."
	@$(QEMU) -kernel $<

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) kernel.bin

.PHONY: all clean run
