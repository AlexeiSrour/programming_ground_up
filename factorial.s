#PURPOSE - Given a number, this porgram computes the
#			factorial. For example, the factorial of
#			3 is 3 * 2 * 1, or 6. The factorial of
#			4 is 4 * 3 * 2 * 1, or 23, and so on.
#
# This program shows how to call a function recursively

.section .data

.section .text

.globl _start
.globl factorial


_start:
pushl $1			# The first (and only arguement) for the function
call factorial
addl $4, %esp		# return stack to prefunction call

movl %eax, %ebx		# save function return as return code
movl $1, %eax		# the exit() syscall
int $0x80

.type factorial, @function
factorial:
pushl %ebp
movl %esp, %ebp

movl 8(%ebp), %eax	# loading parameter value
cmpl $1, %eax		# checking parameter for base case
jne recursion		# fall through to return, otherwise do a recursion
epilogue:
movl %ebp, %esp
popl %ebp
ret

recursion:
decl %eax
pushl %eax			# pushing the new parameter for the recursive call
call factorial
addl $4, %esp		# cleaning stack to prefunction call

imull 8(%ebp), %eax	# eax stores the return of factorial, 8(%ebp) is the original value
jmp epilogue
