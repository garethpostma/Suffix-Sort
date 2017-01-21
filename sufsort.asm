;Writen by Gareth Postma
;MAC id: postmagn
;Student #: 001422248
;Lab Section: 04
;Course: SFWRENG 2XA3

%include "asm_io.inc"

segment .data

msg1 db "You can only enter one input", 0
msg2 db "You may only enter 1's, 2's or 0's", 0
msg3 db "You have a character in your input", 0
msg4 db "You entered too many values", 0
max dd 30
inputLng dd 0
value2 db '2'
value0 db '0'
count dd 0	;store amount of value counted in loop
count2 dd 0
count3 dd 0

; uninitialized data is put in the .bss segment

segment .bss
 
i resd 1
j resd 1
input1 resd 10 ;store initial input
input2 resd 10 ;store input for subroutine
X resd 10 ;stores the input string
n resd 30 ;stores array of numbers that will be bubble sorted

segment .text
	global  asm_main
asm_main:

        enter   0,0               ; setup routine

	mov     eax, dword [ebp+12]	;eax holds address of program name
	add     eax, 8 			;eax holds address of second argument
	mov     ebx, dword [eax]	;ebx stores the value of the second argument

;this if statement check to see if correct number of arguments where entered
        CheckArg: cmp ebx, 0x00		;make sure there isn't a second argument
	je CheckArg_End			;if no value then continue program	
                mov     eax, dword msg1	;store first message
                call    print_string	;print message
                call    print_nl
		jmp end			;jump to the end of the program
        CheckArg_End:

        sub     eax, 4			;eax stores address of first argument
	mov	eax, [eax]		;eax stores value of first argument
	mov	[input1], dword eax	;store aregument into 'input1'
	mov	al, byte [eax]		;store first character of argument in al

;this loop finds the length of the input
	GetLength: cmp al, 0x00		;loop till the end of the string
	je GetLength_End		

;this if statement makes sure values are less than or equal to 2
		CheckLess: cmp al, [value2]	;compare character to value '2'
		jle CheckLess_End		;if less or equal then continue
			mov 	eax, msg2	;store second message
			call	print_string	;print message
			call	print_nl;
			jmp	end		;skip to end of program
		CheckLess_End:

;this if statement makes sure values are greater than or equal to 0
		CheckGreater: cmp al, [value0]	;compare character to value '0'
		jge CheckGreater_End		;if greater or equal then continue
			mov 	eax, msg3	;store third message
			call	print_string	;print it
			call	print_nl	
			jmp	end		;skip to end of program
		CheckGreater_End:

		add	[count], dword 1	;increase 'count' by i
		mov	ebx, [input1]		;ebx stores value of 'input1'
		add	ebx, [count]		;move to character at 'count' position
		mov	al, byte [ebx]		;store character in al
      		jmp	GetLength		;continue loop
	GetLength_End:
	
	mov	eax, dword[count]		;eax stores length of input

;this if statement compares the length of the string to the maximum length of 30
	CheckLength: cmp eax, [max]		;compare length to 'max'
	jle CheckLength_End			;if less or equal continue
		mov	eax, msg4		;eax stores fourth message
		call	print_string		;print message
		call	print_nl
		jmp	end			;skip to end of program
	CheckLength_End:
	
	mov	eax, dword [count]		;store length of input in eax
	mov	[inputLng], eax			;store length into 'inputLng'
	mov	[count], dword 0		;'count' moved to '0'
	mov	eax, [inputLng]			;eax stores input length

;this loop stores each character into 'X' and creates a array of numbers from 0 to N-1
	StoreX: cmp [count], eax		;compare 'count' to input length
	je StoreX_End				;if equal break loop
		mov	ebx, [count]		;ebx stores value of 'count'
		mov     edx, [input1]		;edx stores input string
                add     edx, [count]		;edx starts in input at 'count'
		mov	al, byte [edx]		;al stores first character in edx
		mov	[X+ebx], al		;store character in 'X' at address ebx
		mov	[X+ebx+1], byte 0	;store a 0 at the end of the string 'X'
		mov	[n+ebx*4], dword ebx	;stores number in ebx into array 'n'
		add	[count], dword 1	;increase count by 1
		mov	eax, [inputLng]		;move eax back to input length
		jmp	StoreX 			;return to top of loop
	StoreX_End:

	mov eax, dword[inputLng]		;store input length into eax
	mov [count], dword eax			;mov count to input length

;these loops call the sufcmp and bubble sorts n so we know where each suffix must go
	Loop1: cmp [count], dword 0		;compare 'count' to 0
	je Loop1_End				;if equal break loop
		mov [count2], dword 1		;mov 'count2' to 0
		mov ebx, [count]		;mov ebx to value of 'count'
		Loop2:  cmp [count2], ebx	;compare 'count2' to 'count'
		je Loop2_End			;if equal break inner loop
			mov ebx, dword [count2]	;ebx stores value of 'count2'
			mov eax, [n+ebx*4]	;eax stores int from 'n' at address ebx
			push dword eax		;push value to stack
			sub [count2], dword 1	;decrement 'count2' by 1
			mov ebx, dword [count2]	;store 'count2' into ebx
			mov eax, [n+ebx*4]	;eax store int from 'n' at address ebx
			push dword eax		;push second int to stack
			add [count2], dword 1	;return 'count2' to previous value
			push dword X		;push the input
			call sufcmp		;call subroutine
			cmp eax, 0		;compare returned value to 0
			jl Skip			;if less than zero do nothing
				mov ebx, [count2]	;move ebx to 'count2' (j)	
				sub [count2], dword 1	;decremement 'count2' by 1
				mov ecx, [count2]	;ecx stores value of (j-1)
				add [count2], dword 1	;return 'count2' to prev val
				mov eax, [n+ebx*4]	;store int at n[j] to eax
				mov edx, [n+ecx*4]	;store int at n[j-1] to edx
				mov [n+ebx*4], edx	;store int at n[j-1] to n[j]
				mov [n+ecx*4], eax	;store int at n[j] to n[j-1]
			Skip:		
			mov ebx, [count]	;move ebx back to 'count'
			add [count2], dword 1	;increase 'count2' by 1
			jmp Loop2		;return to top of 'Loop2;
		Loop2_End:
		sub [count], dword 1		;decrement 'count' by 1
		jmp Loop1			;return to top of 'Loop1'
	Loop1_End:
	
	mov ecx, [inputLng]			;ecx stores length of input
	mov [count2], dword 0			;move 'count2' to 0

;this double loop goes through each suffix and prints it char by char
	FinalOutput: cmp [count2], ecx		;compare 'count2' to length of input
	je FinalOutput_End			;if equal end loop
		mov ebx, [count2]		;ebx stores value of 'count2'
		mov eax, [n+ebx*4]		;eax stores n[ebx]
		mov [count], eax		;move 'count' to value of n[ebx]
        	Print1: cmp [count], ecx	;compare 'count' to input length
                	je Print1_End		;if equal end 'Print1'
                       	mov ebx, [count]	;ebx stores value of 'count'
		    	mov eax, [input1]	;eax stores value of 'input1'
		     	add eax, ebx		;move eax to char at 'count'
		       	mov al, byte [eax]	;store char into al
                        call print_char		;print that char
			add [count], dword 1	;increase 'count' by 1
                        mov ecx, [inputLng]	;move ecx back to value of input length
                	jmp Print1		;restart loop
       		 Print1_End:
		call print_nl			;after each value print a new line
		add [count2], dword 1		;increase 'count2' by 1
		jmp FinalOutput			;restart 'FinalOuput'
	FinalOutput_End:

	
	end:		;location called when initial input is not correct
	mov eax, 3          ; Read user input into intput1 (wait for return key) 
    	mov ebx, 1          
    	mov ecx, input1
    	int 80h 	

	mov     eax, 0 				;terminate code
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;

sufcmp:
	enter 0, 0		;setup routine

	mov edx, dword [ebp+8]	;store input string in edx
	mov [input2], edx	;put string into 'input2'
	mov ebx, dword [ebp+12]	;store i value in ebx
	mov ecx, dword [ebp+16]	;store j value in ecx
	mov [i], ebx		;put i value into variable 'i'
	mov [j], ecx		;put j value into variable 'j'

	mov     al, byte [edx]		;store first character of input into al
	mov	[count3], dword 0	;move 'count3' to 0

;this loop will find the length of the input string
        GetLength_2: cmp al, 0x00	;compare character to null	
        je GetLength_2_End		;if equal then end loop
		add	[count3], dword 1 ;increase 'count3' by 1
                mov     ebx, [input2]	;store input string into ebx
                add     ebx, [count3]	;move to 'count3' location in input string
                mov     al, byte [ebx]	;store that character into al
                jmp     GetLength_2	;return to top of loop
        GetLength_2_End:

	mov eax, dword [count3]		;eax contains value of 'count3'
	sub eax, [i]			;move eax to value of len(Z)-i
	mov ebx, dword [count3]		;ebx contains value of 'count3'
	sub ebx, [j]			;move ebx to value of len(Z)-j 
	mov [count3], dword 0		;move 'count3' to 0
	mov ecx, eax			;ecx contains eax 
	cmp eax, ebx			;compare eax to ebx
	jl Compare			;if eax is smaller then skip to next loop
	mov ecx, ebx			;ecx contains ebx

;this loop will compare the chars for the two suffixes one at a time
	Compare: cmp [count3], ecx	;compare 'count3' to ecx
		je end_1		;if equal jump to 'end_1'
		mov ebx, [count3]	;ebx contains 'count3'
		add ebx, [i]		;increase ebx by 'i'
		mov eax, [input2]	;eax contains 'input2'
		add eax, ebx		;move to character at location ebx
		mov ebx, [count3]	;ebx contains 'count3'
		add ebx, [j]		;increase ebx by 'j'
		mov edx, [input2]	;edx contains 'input2'
		add edx, ebx		;move to char at location ebx
		mov al, byte [eax]	;mov al to char at location 'i'+'count3'
		mov bl, byte [edx]	;mov bl to char at location 'j'+'count3'
		add [count3], dword 1	;increase 'count3' by 1
		
		cmp al, bl		;compare the two characters
		je Compare 		;if equal redo the loop 'Compare'
		jg Compare_End		;if al is greater jump to 'Compare_End'
		mov eax, -1		;otherwise move eax to -1
		call end_2		;jump to end of subroutine
	Compare_End:			
	mov eax, 1			;if al greater make eax = 1
	call end_2			;jump to end of subroutine

	end_1:
	mov eax, -1			;if everything is equal make eax -1
	mov ebx, [i]			;ebx contains 'i'
	mov ecx, [j]			;ecx contains 'j'
	cmp ebx, ecx			;compair 'i' to 'j'
	jg end_2			;if 'i' greater keep eax=-1 and jump to end
	mov eax, 1			;if 'j' greater or equal make eax=1
	
	end_2:				
	add 	esp, 12			;restore stack
	leave				;terminate subroutine
	ret				;the return value will be stored in eax
