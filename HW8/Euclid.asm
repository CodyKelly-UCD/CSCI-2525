TITLE: Euclid.asm

INCLUDE Irvine32.inc

IsPrime proto, num:dword
Modulo proto, divisor:byte, dividend:byte
GetNumberFromUser proto, num:ptr dword, prompt:ptr byte
PrintResults proto num1:dword, num2:dword, res:dword
GetGCD proto, num1:dword, num2:dword, res:ptr dword

.data
var_1 dword 0
var_2 dword 0
result dword 0
getNumberPrompt byte "Please enter a number ",0

.code
main PROC
call Randomize

; Get numbers from user
invoke GetNumberFromUser, ADDR var_1, ADDR getNumberPrompt
invoke GetNumberFromUser, ADDR var_2, ADDR getNumberPrompt

; If either of the numbers are prime, we're done
mov result, 1

invoke IsPrime, var_1
cmp eax, 1
je done

invoke IsPrime, var_2
cmp eax, 1
je done

INVOKE GetGCD, var_1, var_2, ADDR result
mov eax, result
call WriteDec

done:

exit
main ENDP

GetGCD proc, num1:dword, num2:dword, res:ptr dword
local quotient:dword
pushad

; First check to see if num1 is greater than num2. If it is, switch them.
mov eax, num1
cmp eax, num2
ja start
xchg eax, num2
mov num1, eax

start:
mov eax, 0
mov edx, 0
mov ax, word ptr num1
div word ptr num2
cmp edx, 0
jz done
mov esi, res
mov [esi], edx
invoke GetGCD, num2, quotient, res

done:
popad
ret 12
GetGCD endp

PrintResults proc num1:dword, num2:dword, res:dword

ret 12
PrintResults endp

GetNumberFromUser proc, num:ptr dword, prompt:ptr byte
pushad
mov edx, prompt
call WriteString
call ReadInt
mov esi, num
mov [esi], eax
popad
call crlf
ret 8
GetNumberFromUser endp



IsPrime proc, num:dword
LOCAL i:dword, divisor:byte
cmp num, 1
jbe is_false

cmp num, 3
jbe is_true

mov divisor, 2
invoke Modulo, divisor, byte ptr num
cmp eax, 0
je is_false

mov divisor, 3
invoke Modulo, divisor, byte ptr num
cmp eax, 0
je is_false

mov i, 5

loopdeeloop:
mov al, byte ptr i
mov ah, byte ptr i
mul al
cmp eax, num
ja is_true
push eax
invoke Modulo, byte ptr i, byte ptr num
cmp eax, 0
pop eax
jz is_false

add i, 2

push eax
invoke Modulo, byte ptr i, byte ptr num
cmp eax, 0
pop eax
jz is_false

add i, 4
loop loopdeeloop

is_true:
mov eax, 1
jmp done
is_false:
mov eax, 0
done:
ret 1
IsPrime endp

Modulo proc, divisor:byte, dividend:byte
; Description:
; Performs a Modulo operation on an integer
;
; Returns:
; EAX: result
mov eax, 0
mov al, dividend
div divisor
mov al, ah
mov ah, 0
ret 8
Modulo endp

END main