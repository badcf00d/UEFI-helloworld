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

section .text


global _start   ; allows the linker to see this symbol
%include "src/include/typedefs.asm" 

_start:
    ; save the location of UEFI
    mov [ptrUEFI], rsp

    mov [hndImageHandle], rcx   ; The UEFI Firmware puts the EFI_HANDLE in argument 1, rcx
    mov [ptrSystemTable], rdx   ; The UEFI Firmware puts the EFI_SYSTEM_TABLE in argument 2, rdx

    mov rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]    ; ConOut is a EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL for the default console
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen]    ; clear the screen

    ; display any errors
    ;cmp rax, EFI_SUCCESS
    ;jne errorCode
    mov rax, 9223372036854775809
    jmp errorCode

    lea rcx, [strHello]                         ; pointer to our string
    call efiOutputString

    jmp $                                       ; loop forever


error:
%ifdef return_uefi
    mov rsp, [ptrUEFI]
    ret
%else
    jmp $
%endif

errorCode:
    push rax        ; save the error code for the UEFI
    push rax        ; working copy of the error code for printing
    mov rax, 19     ; an error code is 19 numbers long
    push rax

    mov rcx, strErrorCode
    call efiOutputString
    
    call funIntegerToAscii
    
    ; restore the error code
    pop rax
    jmp error


funIntegerToAscii:
    xor rdx, rdx                ; zero out RDX, it is used as the high word in the division
    mov rax, [rsp + 16]          ; skip over the return address on the stack
    mov rcx, 10                 ; set divisor
    div rcx                     ; quotient in RAX, remainder in RDX
    mov [rsp + 16], rax          ; save to the stack 

    add rdx, 0x30               ; convert to ASCII character

    mov [charBuffer], dx
    lea rcx, [charBuffer]
    call efiOutputString


    mov rax, [rsp + 8]
    dec rax
    mov [rsp + 8], rax
    jnz funIntegerToAscii
    ret

efiOutputString:
    ; set the 2nd argument to the passed in string
    mov rdx, rcx
    
    ; get the EFI_SYSTEM_TABLE
    mov rcx, [ptrSystemTable]
    
    ; set the 1st argument to EFI_SYSTEM_TABLE.ConOut
    ; which is pointing to EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]
    
    ; run EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ret



codesize equ $ - $$

section .data

    strHello                db  __utf16__ `Hello World\0`
    strErrorCode            db  __utf16__ `\r\n\nError Code #\0`
    charBuffer              db  __utf16__ `0\0`
    hndImageHandle          dq  0          
    ptrSystemTable          dq  0          
    ptrUEFI                 dq  0

datasize equ $ - $$
