; Copyright 2018-2019 Brian Otto @ https://hackerpulp.com
; 
; Permission to use, copy, modify, and/or distribute this software for any 
; purpose with or without fee is hereby granted, provided that the above 
; copyright notice and this permission notice appear in all copies.
; 
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH 
; REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY 
; AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, 
; INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM 
; LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE 
; OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR 
; PERFORMANCE OF THIS SOFTWARE.

bits 64         ; generate 64-bit code
default rel     ; default to RIP-relative addressing

section .text   ; contains the code that will run


global _start   ; allows the linker to see this symbol
%include "src/include/typedefs.asm" 

_start:
    mov [hndImageHandle], rcx   ; The UEFI Firmware puts the EFI_HANDLE in argument 1, rcx
    mov [ptrSystemTable], rdx   ; The UEFI Firmware puts the EFI_SYSTEM_TABLE in argument 2, rdx

    mov rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]    ; ConOut is a EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL for the default console
    lea rdx, [strHello]                         ; pointer to our string
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]   ; call the OutputString function with our arguments
    jmp $                                       ; loop forever

codesize equ $ - $$

section .data ; contains the data that will be displayed

    strHello db __utf16__ `Hello World\0`   ; this must be a Unicode string
    hndImageHandle          dq   0          ; stores the EFI_HANDLE
    ptrSystemTable          dq   0          ; stores the EFI_SYSTEM_TABLE

datasize equ $ - $$
