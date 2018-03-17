TITLE inclassMENU.asm
; Author:  Diane Yoha
; Date:  7 March 2018
; Description: This program presents a menu allowing the user to pick a menu option
;              which then performs a given task.
; 1.  The user enters a string of less than 50 characters.
; 2.  The entered string is converted to upper case.
; 3.  The entered string has all non - letter elements removed.
; 4.  Is the entered string a palindrome.
; 5.  Print the string.
; 6.  Exit
; ====================================================================================

Include Irvine32.inc 

;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
maxLength = 51d

.data
UserOption byte 0h
theString byte maxLength dup(0)
theStringLen byte 0
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h
.code
main PROC

call ClearRegisters          ;// clears registers
startHere:
call DisplayMainMenu
call readhex
mov useroption, al

mov edx, offset theString
mov ecx, lengthof theString
mov ebx, offset thestringlen
opt1:
cmp useroption, 1
jne opt2
call clrscr
call option1
jmp starthere

opt2:
cmp useroption, 2
jne opt3
call clrscr
call option2
jmp starthere
opt3:
cmp useroption, 3
jne opt4
call clrscr
call option3
jmp starthere
opt4:
cmp useroption, 4
jne opt5
call clrscr
call option4
jmp starthere
opt5:
cmp useroption, 5
jne opt6
call clrscr
call option5
jmp starthere
opt6:
cmp useroption, 6
jne opt7
call clrscr
call option6
jmp starthere
opt7:
cmp useroption, 7
jne oops
jmp quitit
oops:
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
jmp starthere

quitit:
exit
main ENDP
;// Procedures
;// ===============================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP

DisplayMainMenu proc
;// Description:  Displays the main menu
;// Requires:  Nothing
;// Returns:  Nothing

.data
Menuprompt1 byte 'MAIN MENU', 0Ah, 0Dh,
'==========', 0Ah, 0Dh,
'1. Enter a String', 0Ah, 0Dh,
'2. Convert all elements to lower case',0Ah, 0Dh,
'3. Remove all non-letter elements',0Ah, 0Dh,
'4. Determine if the string is a palindrome (NOT case sensitive)',0Ah, 0Dh,
'5. Display the string',0Ah, 0Dh,
'6. ', 0
Menuprompt2 byte 'EXTRA CREDIT', 0
Menuprompt3 byte ': Determine if the string is a palindrome (case sensitive)', 0Ah, 0Dh,
'7. Exit: ',0Ah, 0Dh, 0h

.code
; Clear screen
call clrscr

; Display first part of main menu
mov edx, offset menuprompt1
call WriteString

; Display the words EXTRA CREDIT in gold
mov eax, 14
mov edx, offset menuprompt2
call SetTextColor
call WriteString

; Reset text color and display the rest of the menu
mov eax, 7
mov edx, offset menuprompt3
call settextcolor
call writestring
ret
DisplayMainMenu endp

option1 proc uses edx ecx
; Description:  Receives a string from the user
;
; Receives:
; EDX: The offset of the byte array to store the string in.
;      Must have 50 elements.
;
; Returns: 
; EDX: string from user
; EBX: length of string
;
; Requires:
; Array must have 50 elements

.data
option1prompt byte 'Please enter a string of characters (50 or less): ', 0Ah, 0Dh, '--->', 0h

.code
push edx       ; saving the address of the string
mov edx, offset option1prompt
call writestring
pop edx

; add procedure to clear string (loop through and place zeros)

call readstring
mov byte ptr [ebx], al     ;//length of user entered string, now in thestringlen

ret
option1 endp

option2 proc uses edx ebx
; Description:  Converts all uppercase letters in string to lowercase
;
; Receives:
; EDX: Offset of string array
; ECX: Length of string array
;
; Returns:  
; EDX: String array with converted letters, if any

clearESI
L2:
mov al, byte ptr [edx+esi]
cmp al, 41h
jb keepgoing
cmp al, 5ah
ja keepgoing
or al, 20h     ;//could use add al, 20h
mov byte ptr [edx+esi], al
keepgoing:
inc esi
loop L2
ret
option2 endp

option3 proc
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

; If the element isn't a capital letter, it may be a lowercase letter
cmp al, 61h
jb notLetter
cmp al, 7bh
jb letter
cmp al, 75h
ja notletter

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
option3 endp

option4 proc
; Description:  Checks if a given string is a palindrome.
; To be a palindrome, the given string must read the same forwards as it
; does backwards. This means that a character at index n must be the same
; as the character at index (length of string - 1) - n, where n is less than or
; equal to (length of string) / 2.
;
; Receives:  
; EDX: Offset of string array
; EBX: Number of characters in string
;
; Returns:  
;
; Requires:  

.data 
palMsg byte " is a palindrome.",0
notPalMsg byte " is not a palindrome.",0
.code
push ebx
push esi
push eax
; ESI will hold the first index to compare
mov esi, 0
; EBX will hold the second
movzx ebx, byte ptr [ebx]
dec ebx

; We're going to loop through as many elements as there
; are in the string, 
push ecx
mov ecx, ebx

; Loop through the string, comparing elements at front and back
L1:
mov al, byte ptr [edx + esi]
cmp al, byte ptr [edx + ebx]
jne notPalindrome
inc esi
dec ebx
cmp esi, ebx
jae palindrome ; If esi (first index) is greater than or equal to 
               ; ebx (second index), we're done.
LOOP L1

palindrome:
; Write results to screen
call WriteString
push edx
mov edx, offset palMsg
call WriteString
call crlf
call waitmsg
jmp complete

notPalindrome:
call WriteString
mov edx, offset notPalMsg
call WriteString
call crlf
call waitmsg

complete:
pop edx
pop ecx
pop eax
pop esi
pop ebx
ret
option4 endp

option5 proc uses edx 
.data
option5prompt byte 'The String is: ', 0h
.code
push edx
mov edx, offset option5prompt
call writestring
pop edx
call writestring
call crlf
call waitmsg
ret
option5 endp

option6 proc
.data 
palMsg2 byte " is a palindrome.",0
notPalMsg2 byte " is not a palindrome.",0
.code
push ebx
push esi
push eax
; ESI will hold the first index to compare
mov esi, 0
; EBX will hold the second
movzx ebx, byte ptr [ebx]
dec ebx

; We're going to loop through as many elements as there
; are in the string, 
push ecx
mov ecx, ebx

; Loop through the string, comparing elements at front and back
L1:
mov al, byte ptr [edx + esi]
cmp al, byte ptr [edx + ebx]
jne notPalindrome
inc esi
dec ebx
LOOP L1

pop ecx

; Write results to screen
call WriteString
push edx
mov edx, offset palMsg
call WriteString
call crlf
call waitmsg
jmp complete

notPalindrome:
call WriteString
mov edx, offset notPalMsg
call WriteString
call crlf
call waitmsg


complete:
pop edx
pop eax
pop esi
pop ebx
ret
option6 endp

END main

