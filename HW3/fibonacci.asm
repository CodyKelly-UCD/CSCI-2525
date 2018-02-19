TITLE fibonacci.asm
COMMENT !
 Completes the following:
   a. fib(n) for n = 2, 3, ..., 10 using an array of the appropriate 
      size and type. Declares a value for fib(0) and fib(1), but all
      remaining elements are calculated by the program.
   b. After the array is filled with required values, the program 
      stores fib(3) through fib(6) in consecutive bytes of the ebx
      register starting from the lowest byte
!
INCLUDE Irvine32.inc

.data
clearECX	 TEXTEQU	 <mov ecx, 0>
clearEAX	 TEXTEQU	 <mov eax, 0>
fibArray	 BYTE 10 DUP(0)
sizeFibArray = ($ - fibArray)
.data?

.code
main PROC
clearECX
clearEAX
mov [fibArray + 1], 1			    ; Set the second element equal to fib(1)
mov ecx, sizeFibArray - 2	    	; Set the loop counter to length of fibArray minus 
                                    ; two because we know the values of the first two elements
mov esi, OFFSET fibArray

fibLoop:
    mov al, [esi]                   ; al = fib(n - 2)
    inc esi
    mov ah, [esi]                   ; ah = fib(n - 1)
    inc esi
    mov [esi], al
    add [esi], ah                   ; fibArray(n) = fib(n-2) + fib(n-1)
    dec esi
    loop fibLoop

mov ebx, DWORD PTR fibArray + 3     ; set ebx equal to fib(3) through fib(6)
call DumpRegs

exit
main ENDP
END main