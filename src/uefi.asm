; Example to print hello world to the screen from the UEFI
;
; Can be used with:
;   make
;   make qemu


bits 64         ; generate 64-bit code
default rel     ; default to RIP-relative addressing
%include "src/include/typedefs.asm" 


section .text   ; contains the program code
global _start   ; allows the linker to see this symbol

_start:

    ; The UEFI Firmware calls this function with 2 arguments:
    ;   Argument 1 (rcx): a pointer to the EFI_HANDLE  
    ;   Argument 2 (rdx): a pointer to the EFI_SYSTEM_TABLE

    mov rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]                    ; ConOut is a EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL for the default console
    mov rdx, strHello                                           ; moves the address of our string into rdx
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]   ; call the OutputString function with our arguments: rcx and rdx
    
    jmp $                                                       ; loop forever


section .data   ; contains the program data
    strHello db __utf16__ `Hello World\0`
