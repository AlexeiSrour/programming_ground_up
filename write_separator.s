# This function outputs a delimiter/separator to the file descriptor

# INPUTS: it takes a file descriptor
# OUTPUTS: writes out a bunch of '=' with newlines either side

.include "linux.s"

.section .data

separator_string:
.ascii "\n====================\n"
.equ separator_string_len, . - separator_string

.section .text
.type write_separator, @function
.globl write_separator

.equ ST_FILEDES, 8
write_separator:
pushl %ebp
movl %esp, %ebp

movl $SYS_WRITE, %eax
movl ST_FILEDES(%ebp), %ebx
movl $separator_string, %ecx
movl $separator_string_len, %edx

int $LINUX_SYSCALL

movl %ebp, %esp
popl %ebp
ret
