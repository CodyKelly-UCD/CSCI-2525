TITLE fibonacci.asm
; Completes the following:
;   a. fib(n) for n = 2, 3, ..., 10 using an array of the appropriate 
;      size and type. Declares a value for fib(0) and fib(1), but all
;      remaining elements are calculated by the program.
;   b. After the array is filled with required values, the program 
;      stores fib(3) through fib(6) in consecutive bytes of the ebx
;      register starting from the lowest byte

INCLUDE Irvine32.inc

.data
clearECX TEXTEQU <mov ecx, 0>
clearEAX TEXTEQU <mov eax, 0>
fibArray BYTE 10 DUP(0)
.data?

.code
main PROC
mov esi, OFFSET fibArray
MOV [esi], 1			    ; Set the second element in fibArray equal to fib(1)
MOV ecx, LENGTHOF fibArray - 2	    ; Set the loop counter to length of fibArray minus 
                                    ; two because we know the values of the first two elements
NEG ecx
fib:
    MOV [esi + ecx], 1
    LOOP fib

exit
main ENDP
END main