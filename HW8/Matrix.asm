TITLE: Matrix.asm

INCLUDE Irvine32.inc

; Prototypes
GetRandomLetter proto, letterPtr:ptr byte
Modulo proto, divisor:byte, dividend:byte
FillMatrix proto, matrixAddr:ptr byte

.data
matrix  byte 5 dup(0)
        byte 5 dup(0)
        byte 5 dup(0)

.code
main PROC
call Randomize

INVOKE FillMatrix, ADDR matrix

exit
main ENDP

; -----------------------------------------------------------------------------
FillMatrix proc, matrixAddr:ptr byte
; Fills a 2-dimensional matrix at a given address with random letters
; Requires: Matrix length and width must be 5
local rowIndex:byte, columnIndex:byte, currentAddr:dword
pushad
mov rowIndex, 5
mov columnIndex, 5

rowLoop:
dec rowIndex
mov ebx, matrixAddr
movzx ecx, rowIndex
mov columnIndex, 5
cmp rowIndex, 0
jz columnLoop
loop1:
add ebx, 5
loop loop1

columnLoop:
; Update current column index
movzx esi, columnIndex

; Put random letter in address
mov currentAddr, ebx
add currentAddr, esi
invoke GetRandomLetter, currentAddr

; Loop to next column or row if needed
dec columnIndex
cmp columnIndex, 0
ja columnLoop
cmp rowIndex, -1
jg rowLoop

popad
ret 4
FillMatrix endp

; -----------------------------------------------------------------------------
Modulo proc, divisor:byte, dividend:byte
; Performs a Modulo operation on an integer
; Returns:
; EAX: result
mov eax, 0          ; Clear EAX
mov al, dividend    ; Set dividend
div divisor         ; Divide by divisor
mov al, ah          ; Move result to al so it's all nice and tidy
mov ah, 0           ; Get rid of pesky leftovers
ret 8               ; Bam, done.
Modulo endp

; -----------------------------------------------------------------------------
GetRandomLetter proc, letterPtr:ptr byte
; Replaces the contents of the byte at the address passed in through letterPtr
; with the ascii value of a random capital letter.
; This letter has a 50% chance of being a vowel and a 50% chance of being
; a consonant.

; Setup
local divisor:byte, dividend:byte, vowels[5]:byte
mov divisor, 2      ; Used to find modulo 2 of a number
mov vowels[0], 'A'
mov vowels[1], 'E'
mov vowels[2], 'I'
mov vowels[3], 'O'
mov vowels[4], 'U'
mov esi, letterPtr
pushad

; First decide whether the letter is a vowel or consonant
mov eax, 100
call RandomRange
mov dividend, al
invoke Modulo, divisor, dividend
cmp eax, 0
je get_consonant

; If vowel
mov eax, 5
call RandomRange
mov bl, vowels[eax]
mov [esi], bl
jmp done

; If consonant
get_consonant:
; First get ascii code of a random capital letter
mov eax, 26
call RandomRange
add eax, 'A'

; Next we'll have to check if the letter is a vowel
; by checking our random ascii code against all vowel codes
mov ecx, 5
find_vowel_loop:
mov ebx, ecx
cmp al, vowels[ebx]
je get_consonant    ; If our code matches one in the vowels array, start over
loop find_vowel_loop
; If we're here, we have a consonant.
mov [esi], al

done:
popad
ret 4
GetRandomLetter endp

END main