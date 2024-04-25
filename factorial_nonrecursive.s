#PURPOSE: A factorial function written without recursion as per "Going Further" in chapter 4

.section .data
input_parameter:
.long 5

.section .text
.globl _start
_start:
pushl input_parameter
call factorial
addl $4, %esp

movl %eax, %ebx

movl $1, %eax			# $1 is the exit() syscall
int $0x80				# $0x80 is the linux syscall handler

# Takes a positive number as parameter and calculates factorial without recursion
.type factorial @function
factorial:
pushl %ebp
movl %esp, %ebp

movl 8(%ebp), %ebx		# This will be the count
movl $1, %eax			# This will be the accumulator/output

loop:
cmpl $1, %ebx
jle end_loop
mull %ebx

decl %ebx
jmp loop

end_loop:

movl %ebp, %esp
popl %ebp
ret
