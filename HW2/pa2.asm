TITLE pa2.asm

INCLUDE Irvine32.inc

.data
; Register-clearing macros
clearEAX TEXTEQU <mov eax, 0>
clearEDX TEXTEQU <mov edx, 0>

; Numbers
negativeBajillion DWORD 0FFFFFFFFh
positiveBajillion DWORD 7FFFFFFFh
one DWORD 1h

; Symbol
SECONDS_IN_DAY = 24*60*60
.data?

.code
main PROC

; Part 1
; Calculating a product
clearEAX
mov ax, 2*3*4*5*6*7

; Part 2.1
; Overflowing EDX
clearEDX
mov edx, positiveBajillion
add edx, one

; Part 2.2
; Using the carry flag
clearEDX
mov edx, negativeBajillion
add edx, one

; Part 3
; Storing the number of seconds in a day
; in the EDX register
clearEDX
mov edx, SECONDS_IN_DAY

call DumpRegs

exit
main ENDP
END main