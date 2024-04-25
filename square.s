# PURPOSE: creating a program which calls a square function and returns as error code
# This is part of the "Use the Concepts" Section of chapter 4

.section .data
input_parameter:
.long -4

.section .text

.globl _start
_start:
pushl input_parameter
call square
addl $4, %esp

movl %eax, %ebx			# Saving the result to ebx

pushl input_parameter
call square_addition
addl $4, %esp

cmpl %eax, %ebx			# Checking the two functions against eachother for correctness
#cmovne $0, %ebx			# if not equal, will return 0 as an error code

mov $1, %eax			# $1 is the exit() syscall on linux
int $0x80				# Calling linux handler

.type square @function
square:
pushl %ebp
movl %esp, %ebp

movl 8(%ebp), %eax
imull %eax, %eax		# the first parameter multiplied by itself, saved to eax

movl %ebp, %esp
popl %ebp
ret

.type square_addition @function
square_addition:
pushl %ebp
movl %esp, %ebp

subl $4, %esp			# Where the result will be accumulated
movl $0, -4(%ebp)		# zero initialising the accumulator

movl 8(%ebp), %eax		# the adder
movl %eax, %edi			# loop counter variable
and $0x7f, %edi			# making sure it's positive

loop:
addl %eax, -4(%ebp)		# maybe should save the input parameter to a register?
decl %edi
cmpl $0, %edi
jne loop

movl -4(%ebp), %eax 	# returning the accumulated value

movl %ebp, %esp
popl %ebp
ret
