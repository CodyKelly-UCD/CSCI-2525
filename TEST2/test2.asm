TITLE: test2.asm

INCLUDE Irvine32.inc

ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>

.data
userChoice byte 0
mainMenuPrompt byte 'MAIN MENU', 0Ah, 0Dh,
'1. Play new game', 0Ah, 0Dh,
'2. Show stats',0Ah, 0Dh,
'3. Exit',0Ah, 0Dh, 0

guessWord byte 14 dup(0)
displayWord byte 28 dup(0)
lettersGuessed byte 11 dup(0)
remainingWordGuesses byte 0
remainingLetterGuesses byte 0
gamesWon byte 0
gamesLost byte 0

.code
main PROC
call ClearRegisters
call Randomize
;call DisplayDirections

startHere:
mov edx, offset mainMenuPrompt
mov ebx, 3
call MenuPrompt

opt1:
; Play new game
cmp al, 1
jne opt2
call clrscr

; Reset game variables
mov ecx, 14
mov edx, offset guessWord
call ClearString
mov edx, offset displayWord
call ClearString
mov ecx, 10
mov edx, offset lettersGuessed
call ClearString
mov remainingWordGuesses, 3
mov remainingLetterGuesses, 10

; Get random word
mov edx, offset guessWord
call GetRandomString

; Update display string
mov edx, offset displayWord
mov eax, offset lettersGuessed
mov ebx, offset guessWord
call UpdateDisplayString

call writeString

jmp starthere

opt2:
; Show stats
cmp al, 2
jne quit
call clrscr
; opt2 stuff here
jmp starthere

quit:
exit
main ENDP

UpdateDisplayString proc
; Description:
; Updates the string that is displayed to the user during gameplay
; Displays an underscore for letters that the user has not guessed yet,
; and displays letters that the user has already correctly guessed.
; Seperates each character with a space
;
; Receives:
; EDX: Offset of display string (displayWord)
; EAX: Offset of string of characters the user has guessed already (lettersGuessed)
; EBX: Offset of string the user is trying to guess (guessWord)
; 
; Returns:
; EDX: Offset of updated display string
; 
; Requires:
; guessWord must be length of 14 characters, displayWord twice that
.data
currentLetter byte 0
currentGuessedLetter byte 0
displayStringStart byte 'Word: ',0

.code
push ecx
push esi
mov ecx, 14
mov esi, 0

; Display "Word: " before displaying displayWord
push edx
mov edx, offset displayStringStart
call WriteString
pop edx

; Now we find out what to display to the user
loop1Start:
push eax
mov al, byte ptr [ebx + esi]
mov currentLetter, al
pop eax

; If the current character is null, return
cmp currentLetter, 0
jz loop1End

; Now if the current letter is in lettersGuessed, we put that letter in displayWord
push esi
mov esi, -1
loop2Start:
inc esi
push ebx
mov bl, byte ptr [eax + esi]
mov currentGuessedLetter, bl
pop ebx

; If the current character is null, the user hasn't guess this one yet: add an underscore
cmp currentGuessedLetter, 0
jnz loop2Continue
mov currentLetter, '_'
jmp loop2end

loop2Continue:
push eax
mov al, currentGuessedLetter
cmp al, currentLetter
pop eax
jne loop2Start      ; If the current letter in lettersGuessed does not equal the one
                    ; in the word the user is trying to guess, move on to the next one

loop2end:
pop esi
push eax

; Add new character to displayWord
push esi
push ebx
; We need to reference displayWord every other character,
; so we multiply esi by 2 temporarily
mov eax, esi
mov bl, 2
mul bl
mov esi, eax
mov al, currentLetter
mov [edx + esi], al
inc esi

; Add a space before next character
mov currentLetter, ' '
mov ah, currentLetter
mov [edx + esi], ah
pop ebx
pop esi
pop eax
inc esi
loop loop1Start

loop1End:
pop esi
pop ecx
ret
UpdateDisplayString endp

GetRandomString proc
; Description:
; Chooses a string for the user to guess
; 
; Receives:
; EDX: Offset of string to store result in
;
; Returns:
; EDX: Offset of string
;
; Requires:
; Length of string must be at least 14 characters long
.data
String0 BYTE "kiwi", 0h
String1 BYTE "canoe", 0h
String2 BYTE "doberman", 0h
String3 BYTE "puppy", 0h
String4 BYTE "banana", 0h
String5 BYTE "orange", 0h
String6 BYTE "frigate", 0h
String7 BYTE "ketchup", 0h
String8 BYTE "postal", 0h
String9 BYTE "basket", 0h
String10 BYTE "cabinet", 0h
String11 BYTE "mutt", 0h
String12 BYTE "machine", 0h
String13 BYTE "mississippian", 0h
String14 BYTE "destroyer", 0h
String15 BYTE "zoomies", 0h
String16 BYTE "body", 0h
String17 BYTE "my", 0h
String18 BYTE "three", 0h
String19 BYTE "words", 0h

wordNumber DWORD 0

.code
push eax

; First we're going to choose a random number from 0 - 19
mov eax, 20
call RandomRange
mov wordNumber, eax

mov eax, 0   ; Our word counter

; Now we're going to loop through every letter of every String defined in the
; .data section, incrementing eax each time we come across a null character
; Once wordNumber is equal to eax, we know we're on the first character of
; the word we need.
push esi
mov esi, 0

continue:
; If the word we're on is the one we want, we're done
cmp eax, wordNumber
je done

; See if current character is a null character
cmp String0[esi], 0
jnz continue2   ; If not, continue to next character

; If we've come across a null character, increment eax. We're on the next word.
inc eax
inc esi
jmp continue

continue2:
inc esi
jmp continue

done:
; Now that we've found the start of the word we're looking for, we store the
; word itself into the string at the offset in edx
mov eax, offset String0
add eax, esi
mov esi, 0
push ebx

continue3:
mov bl, byte ptr [eax + esi]
mov [edx + esi], bl
inc esi
cmp bl, 0 
jne continue3 ; If we haven't hit a null character, continue moving letters

done2:
pop ebx
pop esi
pop eax
ret
GetRandomString endp

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

DisplayDirections proc
.data
ddstring1 byte " __   __  _______  __    _  _______  __   __  _______  __    _ ",0Ah, 0Dh,
"|  | |  ||   _   ||  |  | ||       ||  |_|  ||   _   ||  |  | |", 0Ah, 0Dh,
"|  |_|  ||  |_|  ||   |_| ||    ___||       ||  |_|  ||   |_| |", 0Ah, 0Dh,
"|       ||       ||       ||   | __ |       ||       ||       |", 0Ah, 0Dh,
"|       ||       ||  _    ||   ||  ||       ||       ||  _    |", 0Ah, 0Dh,
"|   _   ||   _   || | |   ||   |_| || ||_|| ||   _   || | |   |", 0Ah, 0Dh, 0
ddstring2 byte "|__| |__||__| |__||_|  |__||_______||_|   |_||__| |__||_|  |__|", 0Ah, 0Dh, 0Ah, 0Dh,
"By Cody Kelly", 0Ah, 0Dh, 0Ah, 0Dh,
"You're somewhere in the western United States, circa 1885. Dust blows around ", 0Ah, 0Dh,
"your feet and the blinding sun beams down onto your head as the ", 0Ah, 0Dh, 0Ah, 0Dh,
"INSTRUCTIONS:", 0Ah, 0Dh,
"You must correctly guess a random mystery word given to you. You may choose ", 0Ah, 0Dh, 0
ddstring3 byte "to either guess letters contained in the word, or, at any time, guess the ", 0Ah, 0Dh, 
"whole word at once. BUT! You only have TEN chances to correctly guess a ", 0Ah, 0Dh,
"letter in the word, and you only have THREE chances to correctly guess the ", 0Ah, 0Dh,
"whole word at once. If you run out of letters to guess, you may try and ", 0Ah, 0Dh, 0
ddstring4 byte "guess the word, and vice versa. If you correctly guess every letter in the ", 0Ah, 0Dh,
"word or correctly guess the whole word, you win!! ", 0Ah, 0Dh, 
"But if you run out of all your guesses, ", 0Ah, 0Dh, 0Ah, 0Dh,
"well...", 0Ah, 0Dh, 0

.code
push edx
mov edx, offset ddstring1
call writestring
mov edx, offset ddstring2
call writestring
mov edx, offset ddstring3
call writestring
mov edx, offset ddstring4
call writestring
call crlf
call waitmsg
pop edx
ret
DisplayDirections endp

MenuPrompt proc
; Description:  
; Displays a menu prompt and receives a choice from 1 to n number of choices
; 
; Receives: 
; EDX: Offset of prompt
; EBX: Maximum user choice (n)
; 
; Returns:  
; EAX: User choice
.data
errorMessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h

.code
call clrscr
push ebx
mov eax, ebx

start:
; Display menu
call WriteString

; Get choice
call ReadHex

; Check if choice is valid
cmp al, bl
ja error
cmp al, 1
jb error
jmp done

error:
call clrscr
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
call clrscr
jmp start

done:
pop ebx
ret
MenuPrompt endp

ClearString proc
; Description:
; Clears a string
; 
; Receives:
; EDX: Offset of string
; ECX: Length of string
push ecx
push esi
mov esi, 0
clearLoop:
mov byte ptr [edx + esi], 0
inc esi
loop clearLoop
pop esi
pop ecx
ret
ClearString endp

END main