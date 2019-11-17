INTEL = 1
CC = gcc
LD = ld
LDFILE = script.ld
OBJCOPY = objcopy

IMG = boot_fat.img
ifeq ($(INTEL), 1)
    SFILE = boot_intel.S
else
    SFILE = boot_AnAT.S
endif

all: $(IMG)

# Step 1: gcc call as let boot.S assemble to boot.o
boot.o: $(SFILE)
	$(CC) -c $(SFILE) -o boot.o

fat.o: fat12.s
	$(CC) -c fat12.s -o fat.o

# Step 2: ld call linker script script.ld let boot.o link to executable file boot.elf
boot.elf: boot.o fat.o
	$(LD) boot.o fat.o -o boot.elf -T $(LDFILE)

# Step 3: objcopy remove unused sections of boot.elf (.pdr, .comment, .note),
#		 Strop all symbol messege, and output binary file boot.bin
boot.bin: boot.elf
	@$(OBJCOPY) -R .pdr -R .comment -R .note -S -O binary boot.elf boot.bin

# Step 4: generate img file
$(IMG): boot.bin
	@dd if=boot.bin of=$(IMG) bs=512 count=1 # generate first sector via boot.bin
	@dd if=/dev/zero of=$(IMG) skip=1 seek=1 bs=512 count=2879 # padding zero 

clean:
	@rm -rf boot.o boot.elf boot.bin $(IMG) 
