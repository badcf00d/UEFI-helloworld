NASM = nasm
NASMFLAGS = -f win64
STANDALONE_FLAGS = -Dfill_sector

LINKER = clang
LLD-FLAGS = --target=x86_64-unknown-windows -nostdlib -Wl,-entry:_start -Wl,-subsystem:efi_application -fuse-ld=lld

SRC_DIR = .
SRC = $(wildcard $(SRC_DIR)/*.asm)

OBJ_DIR = .
OBJ = $(SRC:.asm=.obj)

EFI = uefi.efi
BIOS = bios.bin
BOOT_DRIVE = uefi.img

.PHONY: clean qemu all standalone vhd

all: $(OBJ)
	$(LINKER) $(LLD-FLAGS) -o $(EFI) $<

standalone: NASMFLAGS += $(STANDALONE_FLAGS)
standalone: $(OBJ)

clean:
	rm -f $(OBJ) $(BOOT_DRIVE) $(EFI)

qemu:
	qemu-system-x86_64 -bios $(BIOS) -drive file=$(BOOT_DRIVE),format=raw

# needs dosfstools and mtools
vhd:
	dd if=/dev/zero of=$(BOOT_DRIVE) bs=1M count=1
	mkfs.vfat $(BOOT_DRIVE)
	mmd -i $(BOOT_DRIVE) ::EFI
	mmd -i $(BOOT_DRIVE) ::EFI/BOOT
	mcopy -i $(BOOT_DRIVE) uefi.efi ::EFI/BOOT/BOOTX64.EFI

%.obj: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $<
