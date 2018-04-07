TITLE: QUIZ4.asm

INCLUDE Irvine32.inc
.code
main PROC
CALL GetNumber

; If user-entered number is zero, exit program
cmp eax, 0
je exProg

; Else, continue asking for numbers
CALL EvenOrOdd
CALL WaitMsg
CALL CRLF
CALL main
exProg:
exit
main ENDP

GetNumber proc
; Description:
; Gets an integer between 0 and 1,000,000 from user
; Returns:
; EAX: User-entered integer
.data
prompt BYTE "Please enter and integer between 1 and 1,000,000: ", 0
.code
; Prompt user for number
mov edx, offset prompt
CALL WriteString
CALL ReadInt
CALL crlf

; Check if number is within the correct range
cmp eax, 1000000
ja error
cmp eax, 0
jb error
jmp continue

; If number is outside range, try again
error:
call GetNumber

; If number is within range, return
continue:
ret
GetNumber endp

EvenOrOdd PROC
; Description:
; Converts a decimal to a binary number
; Counts the number of ones in the binary number
; Determines if the number is even or odd
;
; Receives:
; EAX: Integer
.data
msg1 BYTE "The number is ",0
msg2 BYTE ". There is/are ",0
msg3 BYTE " one(s).",0
.code
CALL CountOnes
push edx
mov edx, offset msg1

ret
EvenOrOdd endp

CountOnes proc
; Description:
; Converts a decimal number to binary
; Counts the number of ones in that binary number
; 
; Receives:
; EAX: Decimal number
; 
; Returns:
; DL: One if odd, zero if even
; DH: Number of ones
; 
.data
divisor DWORD 2
oneCount WORD 0
oddBool BYTE 0
.code
push eax
; Divide once to see if number is even or odd
mov edx, 0
div divisor
mov oddBool, dl
pop eax
push eax
divide:
mov edx, 0
mov ecx, 2
div divisor

; increment oneCount if remainder is one
cmp dl, 1
jne divide
inc oneCount

; If eax is 1, we're done
cmp eax, 1
jne divide
inc oneCount
mov dl, oddBool
mov dh, oneCount
pop eax
ret
CountOnes endp

END main