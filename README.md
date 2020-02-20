# UEFI-helloworld
A hello world example for UEFI written in x86 NASM assembly

#### How to use:
Running `make` will:
 - Assemble the files from `src` into win64 object files, and put them in `obj`
 - Link the win64 object files from `obj` into a PE32+ executable, and put it in `efi`
 - Create a FAT32 .img file in the current working directory, and move the PE32+ executable from `efi` into that .img file at the location `EFI/BOOT/BOOTX64.EFI` which is the default filename for a 64-bit UEFI application.

You can then run `make qemu` to boot that UEFI application with the UEFI provided by OVMF from the <a href="https://github.com/tianocore/tianocore.github.io/wiki/OVMF">TianoCore project</a> that's stored in `inc`.

