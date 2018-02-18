TITLE reorder.asm
; Rearranges the values of an array into a different order
; Uses only: 
; MOV and XCHG
; Direct offset addressing

INCLUDE Irvine32.inc

.data
clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
arrayD DWORD 32, 51, 12
.data?

.code
main PROC

clearEAX
clearEBX
MOV eax, [arrayD]		; Move 32 to EAX
XCHG eax, [arrayD + 4]	; Exchange 32 and 51
XCHG eax, [arrayD + 8]	; Exchange 51 and 12
MOV [arrayD], eax		; Move 12 to first position

exit
main ENDP
END main