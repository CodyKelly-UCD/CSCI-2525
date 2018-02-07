TITIE Troubleshoot.asm

INCLUDE Irvine32.asm

rows = 2 * 3
PressKey equ <Press a Key to continue.  >

.data
a word ae32h
b dword 015b
c byte 32d
astr byte "this is a string"
anArr word ? , 32, 32h,
word "th", 'is', ah

.code
main PROC
mov eax, 0
mov ebx, eax
mov eax, a; put a in eax
mov ebx, b; put b in ebx
mov a, b; a = b
add a, b; a = c + b
mov c; ebx; c = ebx
mov bl, [anArray + 3]



exit
main
END main