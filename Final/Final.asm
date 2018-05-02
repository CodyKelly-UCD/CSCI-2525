TITLE: Final.asm

INCLUDE Irvine32.inc

Menu proto maxOption:dword, prompt:ptr byte, choice:ptr dword, errorMsg: ptr byte
ConnectThree proto modePrompt:ptr byte, columnPrompt:ptr byte, errorMsg:ptr byte
GetGameMode proto prompt:ptr byte, errorMsg:ptr byte, playerTypesAddr:ptr byte
ChooseFirstPlayer proto playerNumber:ptr byte
DisplayGrid proto gridAddr:ptr byte

.data
mainMenuPrompt byte "Welcome! Please select an option:", 0Ah, 0Dh, "1) Play Connect Three", 0Ah, 0Dh, "2) Show stats", 0Ah, 0Dh, "3) Exit", 0
gameModePrompt byte "Welcome to Connect Three! Please select a game mode:", 0Ah, 0Dh, "1) Human vs. human", 0Ah, 0Dh, "2) Human vs. computer", 0Ah, 0Dh, "3) Computer vs. computer", 0
selectColumnPrompt byte "Please select a column to drop your piece (1 - 5): "
invalidChoicePrompt byte "You have entered an invalid choice. Please enter a number from 1 to ",0
maxMenuOption dword 3
userChoice dword 0
playerTypes byte 2 dup(0)
currentPlayer byte 0
grid    byte 4 dup(0)
gridLength = ($ - grid)
        byte 4 dup(0)
        byte 4 dup(0)
        byte 4 dup(0)

s1 byte, "You've selected option ", 0
.code
main PROC
call Randomize

start:
; Display main menu and get user's choice
call ClrScr
INVOKE Menu, maxMenuOption, ADDR mainMenuPrompt, ADDR userChoice, ADDR invalidChoicePrompt

opt1:
; Play Connect Three
cmp userChoice, 1
jne opt2
INVOKE GetGameMode, ADDR gameModePrompt, ADDR invalidChoicePrompt, ADDR playerTypes
INVOKE ChooseFirstPlayer, ADDR currentPlayer
call ClrScr
INVOKE DisplayGrid, ADDR grid
call waitMsg
jmp start

opt2:
; Show stats
cmp userChoice, 2
jne done
mov edx, offset s1
mov eax, 3
call ClrScr
call WriteString
call WriteDec
call CRLF
call WaitMsg
jmp start

done:
exit
main ENDP

; -----------------------------------------------------------------------------
Menu proc maxOption:dword, prompt:ptr byte, choice:ptr dword, errorMsg:ptr byte
; Displays the prompt given, gets a selection from the user, checks if the
; selection is more than or equal to one and less than or equal to maxOption,
; and stores the result into the memory at choice.
;
; Receives:
; maxOption: The maximum number the user is allowed to select.
; prompt: A pointer to a string telling the user what they're selecting.
; choice: A pointer to where this procedure should store the result
; errorMsg: This string is displayed when the user selects an invalid option
;
; Returns:
; choice: The number of the menu option the user chose.

LOCAL beginString:dword, period:dword
mov beginString, '>'
mov beginString[1], ' '
mov period, '.'

pushad

start:
; First let's display the menu prompt
mov edx, prompt
call WriteString
call CRLF
lea edx, beginString
call WriteString

; Receive the user's option
mov esi, choice
call ReadHex
mov [esi], eax

; Check to see if the input is within the valid range
; Start over if:
; The number is below 1
mov eax, 1
cmp [esi], eax
jb tryAgain
; The number is above the max range
mov eax, maxOption
cmp [esi], eax
ja tryAgain

; If we're here, then the user successfully entered a menu option. 
; Yay for them!
jmp done

tryAgain:
; If we're here, the user's gone and messed up. Let's ask them to try again.
; First we display the main part of the error message
call ClrScr
mov edx, errorMsg
call WriteString

; Then we output the upper limit of correct choices.
mov eax, maxOption
call WriteDec
lea edx, period
call WriteString
call CRLF
call WaitMsg
call ClrScr

; And start over
jmp start

done:
ret 16
Menu endp

; -----------------------------------------------------------------------------
GetGameMode proc prompt: ptr byte, errorMsg: ptr byte, playerTypesAddr:ptr byte
; This procedure asks the user to choose a Connect Three game mode.
; The user will choose either:
; 1) Human vs. human
; 2) Human vs. computer
; 3) Computer vs. computer
LOCAL maxOptions:dword, choice:dword, choiceAddr: ptr dword
pushad

lea eax, choice
mov choiceAddr, eax
mov choice, 0

; Display game mode menu and get user option
mov maxOptions, 3
call ClrScr
INVOKE Menu, maxOptions, prompt, choiceAddr, errorMsg

mov esi, choice
mov eax, [esi]

; Now we set up our game with the correct player types
humanVsHuman:
cmp eax, 1
jne humanVsComputer
mov playerTypesAddr[0], 1   ; One for human
mov playerTypesAddr[1], 1
jmp done

humanVsComputer:
cmp eax, 2
jne computerVsComputer
mov playerTypesAddr[0], 1
mov playerTypesAddr[1], 0   ; Zero for computer
jmp done

computerVsComputer:
mov playerTypesAddr[0], 0
mov playerTypesAddr[1], 0

done:
popad
ret 12
GetGameMode endp

; -----------------------------------------------------------------------------
ChooseFirstPlayer proc playerNumber:ptr byte
; Gets a random number, either 1 or 0, and stores it at the address in
; playerNumber
;
; Receives:
; playerNumber: The address to store the result
;
; Returns:
; Either a 1 or 0 at the address in playerNumber
push eax
push esi
mov eax, 1
call RandomRange
mov esi, playerNumber
mov byte ptr [esi], al
pop esi
pop eax
ret 4
ChooseFirstPlayer endp

DisplayGrid proc gridAddr:ptr byte
LOCAL rowCount:byte
pushad

mov rowCount, 0
lea eax, grid

; First output top of grid
; Top left corner
mov al, 201
call WriteChar

; Middle 
mov ecx, 7
L1:
push ecx
shr ecx, 1
jc odd
; ECX is even
mov al, 209
call WriteChar
jmp L1done
odd:
; ECX is odd
mov al, 205
call WriteChar
L1done:
pop ecx
loop L1

; Top right corner
mov ecx, 7
mov al, 187
call WriteChar
call CRLF

; Then output middle of grid
start:
mov ecx, 4
mov esi, 0

; Start row
mov al, 186
call WriteChar
L2:
; TODO: Output colored block depending on contents of matrix here
mov al, ' '
call WriteChar

; If we're at the last column, skip writing last seperator
cmp ecx, 1
je RowEnd

; If we're not at the last column,
; Output column seperator
mov al, 179
call WriteChar
LOOP L2

RowEnd:
; Print end-of-row character
mov al, 186
call WriteChar

; Check if we're on the last row
call CRLF
inc rowCount
cmp rowCount, 4
je printBottom

; Print row divider
; Print left side
mov al, 199
call WriteChar

; Middle 
mov ecx, 7
L3:
push ecx
shr ecx, 1
jc odd2
; ECX is even
mov al, 197
call WriteChar
jmp L3done
odd2:
; ECX is odd
mov al, 196
call WriteChar
L3done:
pop ecx
loop L3

; Print right side
mov ecx, 7
mov al, 182
call WriteChar
call CRLF

jmp start

printBottom:
; Finally, output bottom of grid
; Bottom left corner
mov ecx, 7
mov al, 200
call WriteChar

; Middle 
L4:
push ecx
shr ecx, 1
jc odd3
; ECX is even
mov al, 207
call WriteChar
jmp L4done
odd3:
; ECX is odd
mov al, 205
call WriteChar
L4done:
pop ecx
loop L4

; Bottom right corner
mov ecx, 7
mov al, 188
call WriteChar
call CRLF

popad
RET 4
DisplayGrid endp

END main