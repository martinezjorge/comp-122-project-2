mov r0,#'A'
swi 0x00

strb r0,=MyString

ldr r0,=MyString
swi 0x02


mov r0,#'\n'
swi 0x00

mov r0,#66
swi 0x00


swi 0x11

MyString: .skip 256