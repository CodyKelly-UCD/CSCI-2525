TITLE: Strings.asm

COMMENT !
This program receives an unsigned integer N from the user. It then generates N 
number of strings containing a set of random ascii codes. 
After each string is generated, it's written to the screen in a random color.
!

INCLUDE Irvine32.inc

.data
clearEAX TEXTEQU <MOV eax, 0>
clearEDX TEXTEQU <MOV edx, 0>
clearECX TEXTEQU <MOV ecx, 0>
clearEBX TEXTEQU <MOV ebx, 0>
clearESI TEXTEQU <MOV esi, 0>
string BYTE 32 DUP(0)
N DWORD 0

.code
main PROC
; Get input from user
CALL EnterInt
MOV N, eax

; Generate and display strings
MOV ecx, N
MOV edx, OFFSET string
CALL RStr
CALL WaitMsg
exit
main ENDP

EnterInt PROC
; Gets an unsigned integer from the user
;
; Returns:
; EAX: Unsigned integer entered by user
.data
prompt BYTE "Please enter an unsigned integer (must be 1 or more): ", 0

.code
PUSH edx
MOV edx, OFFSET prompt
CALL WriteString    ; Prompt user for input
CALL ReadDec        ; Get user's input
CALL Crlf
POP edx
RET
EnterInt ENDP

RStr PROC
; Generates a number of random strings
; The strings generated contain only ascii characters
; in a specific range (from minAsciiCode to, but not including,
; asciiRange + minAsciiCode)
; After generation, the strings are written to the
; screen.
;
; Receives: 
; ECX: N, where N is the number of strings to generate
; EDX: Offset of array to store string in
.data
L BYTE 0            ; Length of string generated
minAsciiCode = 41h  ; Minimum ascii code generated
asciiRange = 26     ; This sets the upper bound of codes generated
                    ; to minAsciiCode + asciiRange - 1

.code
PUSH eax
CALL Randomize
L1:
    PUSH ecx
    PUSH edx
    
    ; Get random string length from 7 to 32
    MOV eax, 26
    CALL RandomRange
    ADD eax, 7
    MOV L, al
    MOVZX ecx, L

    ; Fill array with random ascii codes
    L2:
        ; Get random ascii code
        MOV eax, asciiRange
        CALL RandomRange
        ADD eax, minAsciiCode
        
        ; Move it into current array element
        MOV [edx], eax
        
        ; Go to next element
        INC edx
        LOOP L2

    POP edx
    POP ecx
    CALL extracredit
    CALL Crlf
    LOOP L1
CALL Crlf

; Make text color gray again
MOV eax, 7
CALL SetTextColor
POP eax
RET
RStr ENDP

extracredit PROC
; Writes a string in a random color
;
; Receives: 
; EDX: Offset of string to write
PUSH eax
CALL GetRandomColor
CALL SetTextColor
CALL WriteString
POP eax
RET
extracredit ENDP

GetRandomColor PROC
; Generates a random color code
;
; Returns:
; EAX: Color code
;
; Requires:
; Randomize to be called beforehand
clearEAX
MOV eax, 16
CALL RandomRange
RET
GetRandomColor ENDP

END main