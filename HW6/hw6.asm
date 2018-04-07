TITLE: hw6.asm

INCLUDE Irvine32.inc

ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
maxLength = 51d

.data
phrase BYTE maxLength DUP(0)
phraseLength BYTE 0
phraseSet BYTE 0
phrasePrompt byte 'Please enter a phrase (50 characters or less): ',0

key BYTE maxLength DUP(0)
keyLength BYTE 0
keySet BYTE 0
keyPrompt byte 'Please enter a key (50 characters or less): ',0

errorMessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h
invalidMessage byte 'Please enter both a key and a phrase before attempting to encrypt/decrypt.', 0ah, 0dh, 0

userChoice byte 0

.code
main PROC
call ClearRegisters

startHere:
mov edx, offset phrase
mov al, phraseSet
call DisplayMainMenu
call ReadHex
mov userChoice, al

opt1:
; Get a phrase from the user, then format it
cmp userChoice, 1
jne opt2
call clrscr
mov edx, offset phrase
mov eax, offset phrasePrompt
mov ebx, offset phraseLength
call EnterString
call ChangeCase
call LettersOnly
mov phraseSet, 1
jmp starthere

opt2:
; Get a key from the user
cmp userChoice, 2
jne opt3
call clrscr
mov edx, offset key
mov eax, offset keyPrompt
mov ebx, offset keyLength
call EnterString
mov keySet, 1
jmp startHere

opt3:
; Encrypt phrase
cmp userChoice, 3
jne opt4

; If either the phrase or key has not been set, this option is invalid
cmp phraseSet, 0
je invalid
cmp keySet, 0
je invalid
mov edx, offset phrase
mov eax, offset key
movzx ecx, [phraseLength]
mov bl, [keyLength]
mov bh, 1
call EncryptDecrypt
jmp startHere

opt4:
; Decrypt phrase
cmp userChoice, 4
jne opt5

; If either the phrase or key has not been set, this option is invalid
cmp phraseSet, 0
je invalid
cmp keySet, 0
je invalid
mov edx, offset phrase
mov eax, offset key
movzx ecx, [phraseLength]
mov bl, [keyLength]
mov bh, 0
call EncryptDecrypt
jmp startHere

opt5:
cmp userChoice, 5
jne oops
jmp quit

oops:
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
jmp starthere

invalid:
push edx
mov edx, offset invalidmessage
call writestring
call waitmsg
pop edx
jmp starthere

quit:
exit
main ENDP

ChangeCase proc
; Description:  Converts all lowercase letters in string to uppercase
;
; Receives:
; EDX: Offset of string array
; EBX: Length of string array
;
; Returns:  
; EDX: String array with converted letters, if any
push esi
push eax
push ecx
clearESI
movzx ecx, byte ptr [ebx]

letterLoop:
mov al, byte ptr [edx+esi]
cmp al, 'a'
jb keepgoing
cmp al, 'z'
ja keepgoing
sub al, 20h
mov byte ptr [edx+esi], al
keepgoing:
inc esi
loop letterLoop

pop ecx
pop eax
pop esi
ret
ChangeCase endp

EncryptDecrypt proc
; Description:
; Shifts characters in a phrase an amount specified in a key
; Or alerts the user if no key is set.
;
; Receives:
; EDX: Offset of phrase to shift
; EAX: Offset of key to use
; ECX: Length of phrase
; BL: Length of key
; BH: 1 if Encyrpting, 0 if decrypting
;
; Returns:
; EDX: Encrypted phrase
.data
theKeyLength byte 0
keyIndex byte 0
phraseIndex byte 0
currentLetter byte 0
encrypt byte 0
.code
mov keyIndex, 0
mov phraseIndex, 0
push esi
mov theKeyLength, bl
dec theKeyLength
mov encrypt, bh
mov ebx, 0

eLoop:
; Get the current key letter
movzx esi, [keyIndex]
mov bl, [eax+esi]
push eax
; Store key letter
mov al, bl
; Get key letter modulo 26d
mov ah, 26
call Modulo
; Shift current phrase letter by modulus result
movzx esi, [phraseIndex]
mov al, [edx + esi]
; Check to see if we're encrypting
cmp encrypt, 0 
jne doShift
; If we're decrypting, make shift amount negative
neg ah
doShift:
call CipherShiftChar
; Store result of shift back into phrase string
mov [edx + esi], al
; Now we'll check if we have to wrap around to beginning of key
mov al, keyIndex
cmp al, theKeyLength
jne continue
mov keyIndex, -1 ; Reset keyIndex
continue:
inc keyIndex
inc phraseIndex
pop eax
loop eloop
pop esi
ret
EncryptDecrypt endp

LettersOnly proc
; Description:  Removes all non-letter characters from string
;
; Receives:
; EDX:  offset of string array
;
; Returns:  
; EDX: offset of string array
; EBX: new length of string
push eax
push esi
push edx
push ebx
clearESI
clearEAX

L1:
; Move current element into al
mov al, byte ptr [edx + esi]

; Test if current element is NOT a capital letter
cmp al, 41h
jb notLetter
cmp al, 5bh
jb letter

letter:
; If current element IS letter:
; Move element into element at ah
movzx ebx, ah
; Make current element 0
mov byte ptr [edx + esi], 0
; Move letter into new position
mov byte ptr [edx + ebx], al
; Increment ah so we get a new valid position
inc ah
jmp keepgoing

notLetter:
; If current element is NOT a letter:
; Make current element 0
mov byte ptr [edx + esi], 0

keepgoing:
inc esi
LOOP L1

complete:
pop ebx
mov byte ptr [ebx], ah  ; Return length of string
pop edx
pop esi
pop eax
ret
LettersOnly endp

EnterString proc
; Description:  
; Displays a prompt and receives a string from the user
;
; Receives:
; EAX: The offset of the prompt string
; EDX: The offset of the byte array to store the string in.
;      Must have 50 elements.
; EBX: The offset of the length of string
;
; Returns: 
; EDX: string from user
; EBX: length of string
;
; Requires:
; Array must have 50 elements
.data
errorMsg byte "You haven't entered anything, please try again.",0
.code
start:
call ClearString
push eax
push edx            ; saving the address of the string
xchg edx, eax       ; flip string offsets
call writestring
xchg edx, eax       ; flip them back
mov ecx, maxLength
call readstring
mov byte ptr [ebx], al     ;//length of user entered string, now in thestringlen
cmp byte ptr [ebx], 0
jne continue
call clrscr
mov edx, offset errorMsg
call writestring
call crlf
call waitmsg
call clrscr
pop edx
pop eax
jmp start
continue:
pop edx
pop eax
ret
EnterString endp

ClearRegisters Proc
; Description:  
; Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;
; Requires:  
; Nothing
;
; Returns:  
; Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP

DisplayMainMenu proc
; Description:  
; Displays the main menu
; 
; Receives: 
; AL: 1 if phrase is entered already, 0 if no phrase has been entered.
; EDX: Offset of phrase
; 
; Returns:  Nothing

.data
Menuprompt1 byte 'MAIN MENU', 0Ah, 0Dh,0
Menuprompt2 byte '1. Enter a phrase', 0Ah, 0Dh,
'2. Enter a key',0Ah, 0Dh,
'3. Encrypt phrase',0Ah, 0Dh,
'4. Decrypt phrase',0Ah, 0Dh,
'5. Exit ',0Ah, 0Dh, 0h
phraseDisplay1 byte 'Current phrase: ',0

seperator byte '==========', 0Ah, 0Dh, 0
.code
call clrscr
push edx

; Display main menu
mov edx, offset menuprompt1
call WriteString
mov edx, offset seperator
call writeString

; If there's a phrase, display it
cmp al, 1
jne continue
mov edx, offset phrasedisplay1
call WriteString
pop edx
call Printit
push edx
call crlf
mov edx, offset seperator
call WriteString

continue:
mov edx, offset menuprompt2
call WriteString
pop edx
ret
DisplayMainMenu endp

CipherShiftChar proc
; Description:
; Shifts a character through the alphabet by a pre-determined
; number of spaces. Wraps around to beginning if necessary.
; To shift a character to the left, pass in a negative number
; To shift a character to the right, pass in a positive number
;
; Receives:
; AH: Number of places to shift character.
; AL: Character to shift.
; 
; Returns:
; AL: Shifted character
add al, ah
cmp al, '@'
ja next
add al, 1ah
next:
cmp al, '['
jb continue
sub al, 1ah
continue:
ret
CipherShiftChar endp

Modulo proc
; Description:
; Performs a Modulo operation on an integer
;
; Receives:
; AH: Divisor
; AL: Dividend
;
; Returns: 
; AH: Result
.data
divisor BYTE 0
.code
mov divisor, ah
mov ah, 0
div divisor
ret
Modulo endp

Printit proc
; Description:
; Outputs a string in the format ***** ***** *****,
; where each * represent a subsequent character in the
; string.
;
; Receives:
; EDX: Offset of string
; 
; Returns:
; Nothing
; 
; Requires:
; String length must be 50
push esi
push ecx
push ax         ; AL will contain current character
                ; AH will contain a counter used to determine when to output a space character
mov esi, 0
mov ax, 0
mov ecx, 50
printLoop:
mov al, [edx + esi]
call WriteChar
inc ah
cmp ah, 5       ; If counter is 4, we output a null character and reset counter
jne continue
mov ax, 0       ; Set both counter and character to output to '0'
call WriteChar
continue:
inc esi
loop printLoop
pop ax
pop ecx
pop esi
ret
Printit endp

ClearString proc
; Description:
; Clears a string
; 
; Receives:
; EDX: Offset of string
; EBX: Offset of size of string
;
; Requires:
; String must have max length of 50
push ecx
push esi
mov esi, 0
mov ecx, 50
clearLoop:
mov byte ptr [edx + esi], 0
inc esi
loop clearLoop
pop esi
pop ecx
ret
ClearString endp

END main