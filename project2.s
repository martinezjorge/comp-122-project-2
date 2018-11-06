
; Comp - 122
; Project - 2
; Programmer: Jorge Martinez


; this should open a file for input
ldr r0,=InFileName					; set Name for input file
mov r1,#0							; input mode
swi 0x66							; open file
bcs InputFileError					; branch if there's an error opening file
ldr r1,=InFileHandle				; load input file handle
str r0,[r1]							; save the file handle

; this should read a string from a file opened for input
ldr r0,=InFileName					; set name for input file
ldr r0,[r1]							; load file handle
ldr r1,=FileString 					; address of an area into which string will be copied into
mov r2,#1024						; max number of bytes to store in memory
swi 0x6a							; read string from file
bcs InputReadError					; branch if there's an error read string from file

; close the file
ldr r0,=InFileHandle				; set name of file
ldr r0,[r0]							; load its handle
swi 0x68							; close the file

ldr r0,=FileString 					; loading FileString into r0 again
mov r1,r0							; then we move into r1 for some reason

TheLoop:

	ldrb r2,[r0]					; then we load a byte from the memory location into r2
	cmp r2,#0						; then we compare it with 0 to make sure its not the null character or end of string
	beq Output 						; if its the null character we'll branch and output to a file
	cmp r2,#'A'						; compare current value with 'A'
	bge Phase1						; if >='A'branch go to Phase1
	blt Copy						; else it can't be in alphabet so we copy it over

Phase1:

	cmp r2,#'z'						; now we check if its <='z'
	ble Phase2						; if its less than or equal to 'z' go to Phase2
	bgt Copy 						; if its greater than it has no chance of being in alphabet

Phase2:

	cmp r2,#'Z'						; now we compare with 'Z'
	ble Upper						; if its less than Z then it has to be an upper case letter
	bgt Phase3						; if its greater than it its either Lower or not in alphabet

Phase3:

	cmp r2,#'a'						; no we compare with a
	bge Lower 						; if its greater than 'a' than it is a lower case letter
	blt Copy 						; if its lower than 'a' than it is not a letter

Lower:

	sub r2,r2,#32 					; we subtract 32 to make it upper case
	cmp r2,r2 						; r2 will always equal it self so this will always be true
	beq Upper 						; now thats its upper case we can send to upper branch

Upper:

	cmp r2,#'A' 					; here we check if its a vowel
	beq Star 						; if its a vowel we replace it with an asterisk
	cmp r2,#'E'
	beq Star
	cmp r2,#'I'
	beq Star
	cmp r2,#'O'
	beq Star
	cmp r2,#'U'
	beq Star
	cmp r2,#'A' 					; if it makes it to here without branching then its not a vowel
	bne Copy 						; so we just copy it over

Star:

	mov r2,#'*' 					; here we replace it with an asterisk
	cmp r2,r2 						; we need something true to branch
	beq Copy 						; now that its an asterisk we sent it to be copied to FileString

Copy:

	strb r2,[r1],#1 				; replace the byte or copy it over
	add r0,r0,#1 					; increment to the next byte
	bal TheLoop 					; start the process again

Output:

	; open file for output
	ldr r0,=OutFileName				; set the name of the file
	mov r1,#1						; open file in output mode
	swi 0x66						; open the file
	bcs OutFileError 				; brance if there's an error
	ldr r1,=OutFileHandle 			; load the file handle
	str r0,[r1]						; save the file handle

	; output modified string to file
	ldr r0,=OutFileHandle 			; load the file handle
	ldr r0,[r0] 					; i think this is what causes the error i get
									; whether this is [r0] [r1] it prints to output.txt but i get the error
	ldr r1,=FileString 				; get modified string ready
	swi 0x69 						; write to the file ; what's weird is that it still write to file anyways
									; here the carry bit is set to 1 ; i implemented this exactly as specified in user guide
	bcs WriteError 					; branch if theres a writing error

	; close the file
	ldr r0,=OutFileHandle			; set name of file
	ldr r0,[r1]						; load its handle
	swi 0x68						; close the file	

	swi 0x11						; program end

; Error Branches

InputFileError:

	ldr r0,=InFileError 			; load InFileError string to register 0
	swi 0x02						; output InFileError to std out
	swi 0x11						; terminate program

InputReadError:

	ldr r0,=ReadInError				; load ReadInError string to register 0
	swi 0x02						; output ReadInError to std out
	swi 0x11						; terminate program

OutFileError:
	ldr r0,=OutFileErrorMessage		; load OutFileErrorMessage into register 0
	swi 0x02						; output message to std out
	swi 0x11 						; terminate program

WriteError:
	ldr r0,=WriteErrorMessage 		; load WriteErrorMEssage into register 0
	swi 0x02 						; output message to std out
	swi 0x11 						; terminate program

; Data Section

InFileName: .asciz	"input.txt"

InFileHandle:.word 0

OutFileName: .asciz "output.txt"

OutFileHandle: .word 0

InFileError: .asciz	"Unable to open input file!\n"
	.align

ReadInError: .asciz "Unable to read from input file!\n"
	.align

OutFileErrorMessage: .asciz "Unable to open output file!\n"
	.align

WriteErrorMessage: .asciz "Unable to write to output file!\n"

FileString: .skip 1024