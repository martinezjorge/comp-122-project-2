.equ SWI_Open, 0x66			@ open a file
.equ SWI_Close,0x68 		@ close a file
.equ SWI_PrChr,0x00 		@ Write an ASCII char to Stdout
.equ SWI_PrStr, 0x69 		@ Write a string to file
.equ SWI_RdStr,0x6a 		@ Read a String from a file
.equ Stdout, 1 				@ Set output target to be Stdout
.equ SWI_Exit, 0x11 		@ Stop execution


.global _start
.text


_start:
@ print an initial message to the screen (project name)
mov R0, #Stdout 			@ print an initial message
ldr R1,=Message1 			@ load address of Message1 label
swi SWI_PrStr @ display message to Stdout

@ == Open an input file for reading =============================
@ if problems, print message to Stdout and exit
ldr r0,=InFileName @ set Name for input file
mov r1,#0 @ mode is input
swi SWI_Open @ open file for input
bcs InFileError @ Check Carry-Bit (C): if= 1 then ERROR

@ Save the file handle in memory:
ldr r1,=InFileHandle @ if OK, load input file handle
str r0,[r1] @ save the file handle
@save output file
ldr r0, =OutFileName
mov r1, #1
swi SWI_Open
ldr r1, =OutFileHandle
str r0, [r1]


@ == Read string ===============================================
Read:
ldr r0,=InFileHandle @ load input file handle
ldr r0,[r0]
ldr r1,=CharArray
mov r2, #'-'
swi SWI_RdStr
bcs Write
ldr r0, =CharArray
ldr r1, =OutArray


Loop:
ldrb r2, [r0], #1
bal EOF

Lowercase:
 add r2, r2, #0 @add 32 to make lowercase @Changed to 0, if uppercase no change
 bal Store

IsHigh:
cmp r2, #-32 @65 @1
bgt isLow @ > 65 could be uppercase
blt isSpace

isLow:
cmp r2, #90
blt Lowercase @ 65 < char < 90 is Uppercase
bgt isPunctHigh

isSpace:
cmp r2, #32
beq Store
bgt isPunctLow

isPunctLow:
cmp r2, #32 @ > 32 could be punctuation
bgt isPunctMid

isPunctMid:
cmp r2, #48
blt ConvertDash @ 32 < char < 48 is punctuation

isPunctHigh:
cmp r2, #90 @90
bgt isPunctHighTwo

isPunctHighTwo:
cmp r2, #1 @97, @1 fixed numbers
blt ConvertDash
bgt isPunctHighThree

isPunctHighThree:
cmp r2, #122 @123
bgt ConvertDash
blt Store

ConvertDash:
ldr r2, =Dash
bal Store


EOF:
cmp r2, #1 @1 @0 @12
blt Write
cmp r2, #127 @1
bgt Write
bcs Write
bal IsHigh


Store:
strb r2, [r1], #1
bal Loop

Write:
ldr r0, =OutFileHandle
ldr r0, [r0]
ldr r1, =OutArray
swi SWI_PrStr
ldr r1, =CRLF
swi SWI_PrStr
@cmp r2, #0x1a
@bne Read
bal Exit


@ == Reading file error =========================================
ReadError:
mov R0, #Stdout
ldr r1, =ReadErr
swi SWI_PrStr
bal Exit


@ == Writing to file error ======================================
WriteError:
mov R0, #Stdout @ print write error
ldr r1, =FileOpenOutMsg
swi SWI_PrStr
bal Exit


InFileError:
mov R0, #Stdout
ldr R1, =FileOpenInpErrMsg
swi SWI_PrStr
bal Exit 							@ give up, go to end

@ == Close files and exit ========================================
Exit:
			@ close output file
ldr r0, =OutFileHandle 				@ get address of file handle
ldr r0, [r0] 						@ get value at address
swi SWI_Close						@close input file
ldr r0, =InFileHandle
ldr r0, [r0]
swi SWI_Close
swi SWI_Exit 						@ stop executing


.data
.align
InFileHandle: .word 0
InFileName: .asciz "input.txt"
OutFileHandle: .word 0
OutFileName: .asciz "output.txt"
CharArray: .skip 80
OutArray: .skip 80
FileOpenInpErrMsg: .asciz "Failed to open input file \n"
FileOpenOutMsg: .asciz "Failed to open output file \n"
EmptyFileMsg: .asciz "The file is empty!\n"
ReadErr: .asciz "Could not read from input file \n"
NL: .asciz "\n"
Dash: .asciz "-"
CRLF: .byte 13, 10, 0
Message1: .asciz "project2.s\n\n"
Goodbye: .asciz "\n\nGood Bye!!"
.end