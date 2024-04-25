#PURPOSE: 	Similar to the power program, this will calculate 2^3 + 5^2
#			but will acheive this without pop or push instructions, but
#			instead use manual register manipulation

# *TIL* pushing, popping, or moving the instruction pointer is actually an ~illegal~ operation and
# no assembler will assemble it. call and ret are actually their own fully fledged opcodes and eip
# is not one of the general purpose registers, so *only* call and ret are legal operations on eip!

.section .data

.section .text
.globl _start
_start:
pushl $3		# second arguement (power)
pushl $2		# first arguement (base)
pushl %eip		# the return address
jmp power
addl $12, %esp	# reset stack pointer to pre function call status

# exiting the programming, value saved in ebx
movl $1, %eax
int $0x80

.type power, @function
power:
pushl %ebp
movl %esp, %ebp

movl $4, %ebp

movl %ebp, %esp
popl %ebp
popl %eip
