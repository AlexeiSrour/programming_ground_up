#PURPOSE:	Program to illustrate how functions work
#			This program will compute the value of
#			2^3 + 5^2
#

# Everything in the main function is stored in registers.
# so the data section doesn't have anything

.section .data

.section .text

.globl _start
_start:
pushl $3			# push second parameter onto stack
pushl $2			# push first parameter onto stack
call power
addl $8, %esp		# move the stack pointer back to before the arguement passing

pushl %eax			# save the first return value to the stack before second function invocation

pushl $2			# push second parameter onto stack
pushl $5			# push first parameter onto stack
call power
addl $8, %esp		# move the stack pointer back to before the arguement passing

popl %ebx			# move the first answer into ebx, eax currently stores the second answer

addl %eax, %ebx		# saves addition to ebx

movl $1, %eax		# 1 is the exit() syscall on linux
int $0x80			# call the syscall handler

#PURPOSE:	This function is used to compute
#			the value of a nimaber raised to
#			a power.
#
#INPUT:		First number - the base number
#			Second arguement - the power to
#							   raise it to
#
#OUTPUT:	Will give the result as a return value
#
#NOTES:		The power must be 1 or greater
#
#VARIABLES:	%ebx - holds the base number
#			%ecx - holds the power
#
#			-4(%ebp) - holds the current result
#
#			%eax is used for temporary storage
#
.type power @function
power:
pushl %ebp			# save old base pointer
movl %esp, %ebp		# move current stack into base pointer
subl $4, %esp		# create area for local storage

movl 8(%ebp), %ebx	# move the first parameter (the base)
movl 12(%ebp), %ecx	# move the second parameter (the power)

movl %ebx, -4(%ebp) # save current result (remember, power will be atleast 1)

power_loop_start:
cmpl $1, %ecx		# checking to see if end of power loop
jle end_power 		# exiting once multiplication has been done enough

movl -4(%ebp), %eax	# reload the current result
imull %ebx, %eax	# saves the multiplication into %eax

movl %eax, -4(%ebp)	# resave the current power
decl %ecx			# decrementing the power

jmp power_loop_start

end_power:
movl -4(%ebp), %eax	# Create the return

movl %ebp, %esp		# delete local storage i.e. stack pointer reset to start of function and points to old ebp
popl %ebp			# pops old ebp value into ebp register i.e. original stack frame restored (now pointiner at ret add)

ret
