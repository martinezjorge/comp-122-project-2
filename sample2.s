
/*

// Pseudocode

while(ReadString(String, 128) != 0)
{
    for(r0 = r1 = String; *r0 != 0; r0++)
    {
        if (IsLower(*r0))
        {
            *r1++ = UpperCase(*r0);
        } else if (IsUpper(*r0) || IsSpace(*r0)) {
            *r1++ = *r0;
        }
    }
    *r0 = 0; /* terminate */
    WriteString(String);
}

*/


_read:

     ldr  r0, =InFileHandle   ;r0 points to the input file handle
     ldr  r0, [r0]            ;r0 has the input file handle
     ldr  r1, =String         ;r1 points to the input string
     ldr  r2, =128            ;r2 has the max size of the input string
     swi  SWI_RdStr           ;read a string from the input file
     cmp  r0,#0               ;no characters read means EOF
     beq  _exit               ;so close and exit

     ldr  r0, =String
     mov  r1, r0

charloop:

     ldrb r2, [r0]
     cmp  r2, #0
     beq  endofstring
     cmp  r2, #'z'
     bgt  skip
     cmp  r2, #'a'
     bge  lower
     cmp  r2, #'Z'
     bgt  skip
     cmp  r2, #'A'
     bge  copy
     cmp  r2, #' '
     beq  copy
     bal  skip

 lower:
     sub  r2, r2, #0x20

 copy:
     strb r2, [r1], #1

 skip:
     add  r0, r0, #1
     bal  charloop

 endofstring:

     strb r2, [r1]            ; copy the terminating zero

     ldr  r0, =OutFileHandle  ;r0 points to the output file handle
     ldr  r0, [r0]            ;r0 has the output file handle
     ldr  r1, =String         ;r1 points to the output string
     swi  SWI_PrStr           ;write the null terminated string
                              
     ldr  r1, =CRLF           ;r1 points to the CRLF string
     swi  SWI_PrStr           ;write the null terminated string
                              
     bal  _read               ;read the next line 