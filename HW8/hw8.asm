TITLE: hw8.asm

INCLUDE Irvine32.inc

GetRandomLetter proto, letter:dword

.data
var_1 dword 0

.code
main PROC
call Randomize

invoke GetRandomLetter, var_1

push eax
pop eax

exit
main ENDP

GetRandomLetter proc, letter:dword
pushad
mov eax, 26
call RandomRange
add eax, 'A'
mov letter, eax
popad
ret 4
GetRandomLetter endp

END main