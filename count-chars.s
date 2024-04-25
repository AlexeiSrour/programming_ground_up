# PURPOSE:		Count the characters until a null byte is reached
#
# INPUT:		The address of the character string
#
# OUTPUT:		Returns the count in %eax
#
# PROCESS:
#	Registers Used:
#		%ecx - character count
#		%al - current character
#		%edx - current character address

.type count_chars, @function
.globl count_chars
.equ ST_STRING_START_ADDRESS, 8
count_chars:
pushl %ebp
movl %esp, %ebp

movl $0, %ecx
movl ST_STRING_START_ADDRESS(%ebp), %edx

count_loop:
movb (%edx,%ecx,1), %al
cmpb $0, %al
je end_loop
inc %ecx
jmp count_loop

end_loop:
movl %ecx, %eax

movl %ebp, %esp
popl %ebp
ret
