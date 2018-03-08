TITLE: template.asm

INCLUDE Irvine32.inc

.data
clearEAX TEXTEQU <MOV eax, 0>
clearEDX TEXTEQU <MOV edx, 0>
clearECX TEXTEQU <MOV ecx, 0>
clearEBX TEXTEQU <MOV ebx, 0>
clearESI TEXTEQU <MOV esi, 0>
string BYTE 32 DUP(0)
prompt BYTE "Please enter an unsigned integer: ",0
.data?

.code
main PROC
clearEAX
clearEDX

; Get input from user
MOV edx, OFFSET prompt
;CALL EnterInt

; Get a random color for strings

; Generate and display a number of random strings
MOV edx, OFFSET string
MOV ecx, eax
;CALL RStr
CALL clearArray

exit
main ENDP

EnterInt PROC
;-----------------------------------------------------
; Gets an unsigned integer from the user
; Receives: 
; EDX: Offset of prompt string
; Returns:
; EAX: Unsigned integer entered by user
;-----------------------------------------------------
CALL WriteString    ; Prompt user for input
CALL ReadDec        ; Get user's input
RET
EnterInt ENDP

RStr PROC
;-----------------------------------------------------
; Generates a random string
;
; I'm not receiving the value from EnterInt in this
; procedure because I couldn't figure out why I needed
; it.
;
; Receives: 
; EDX: Offset of array to store string in
;-----------------------------------------------------
CALL Randomize

; Get random string length from 7 to 32
MOV eax, 26
CALL RandomRange
ADD eax, 7
MOV ecx, eax    ; Store number in ecx

; Fill array with random capital letters
L1:
    ; Get ascii code of a random capital letter
    MOV eax, 26
    CALL RandomRange
    ADD eax, 41h
    ; Move it into current array element
    MOV [edx], eax
    ; Increment index
    INC edx
    LOOP L1

MOV ecx, ebx    ; Restore ecx
RET
RStr ENDP

clearArray PROC
;-----------------------------------------------------
; Sets the contents of a given string to 0
; Receives: 
; EDX: Offset of array
; ECX: Length of array
;-----------------------------------------------------
L1:
    MOV esi, ecx
    MOV edx[esi], 0
LOOP L1
RET
clearArray ENDP

createStrings PROC
;-----------------------------------------------------
; Gets a number of random strings and displays them
; on-screen.
; Receives: 
; ECX: Number of strings to generate
; EDX: Offset of array to store string in
;-----------------------------------------------------



RET
createStrings ENDP

extracredit PROC
; Receives: 
; 
; Returns:
; 
;-----------------------------------------------------
RET
extracredit ENDP

randomColor PROC
; Receives: 
; 
; Returns:
; 
;-----------------------------------------------------
RET
randomColor ENDP

END main