TITLE troubleshoot-1.asm

INCLUDE Irvine32.inc

rows = 2 * 3
PressKey equ <"Press a Key to continue.  ", 0>

.data
aVar word 0ae32h
bVar word 1111b
cVar dword 32d
astr byte "this is a string"
anArr word ? , 32, 32h
byte "th","is","ah", 0
.data?

.code
main PROC
mov eax, 0
mov ebx, eax
mov ax, aVar; put a in eax
mov bx, bVAR; put b in ebx
mov avar, ax; a = b
add cVAR, ebx; c = c + b
mov cVar, ebx; c = ebx
mov bx, [anArr + 1]

exit
main ENDP
END main