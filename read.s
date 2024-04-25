# PURPOSE: Multi use generic function to read from any file desciptor

# Dependancies: none, completely self contained
# inputs: file descriptor, pointer to message buffer, length to read
# ouputs: number of characters read(should always equal length)

# Extra notes: the function will fully read from the given file descriptor, no partial reads

.equ SYS_READ, 3			# Syscall number
.equ LINUX_SYSCALL, 0x80 	# linux syscall trap handler

.type read, @function
.globl read

.equ ST_MSG_LEN, 16		# parameter 2
.equ ST_MSG_BUF, 12		# parameter 1
.equ ST_FILEDES, 8
.equ ST_READ_CHARS, -4	# local storage to track total written out
.equ ST_CURRENT_CHAR, -8	# local storage to point at current letter in buffer
read:
pushl %ebp
movl %esp, %ebp
subl $8, %esp

movl $0, ST_READ_CHARS(%ebp)
movl ST_MSG_BUF(%ebp), %ecx
movl %ecx, ST_CURRENT_CHAR(%ebp)
movl ST_MSG_LEN(%ebp), %ebx

read_loop:
movl ST_CURRENT_CHAR(%ebp), %ecx
movl %ebx, %edx
movl $SYS_READ, %eax
movl ST_FILEDES(%ebp), %ebx
int $LINUX_SYSCALL

addl %eax, ST_READ_CHARS(%ebp)
addl %eax, ST_CURRENT_CHAR(%ebp)

cmpl $0, %eax
movl ST_READ_CHARS(%ebp), %eax
je function_exit		# early return in case of EOF, but not before saving total read characters first
jl function_exit_error
movl ST_MSG_LEN(%ebp), %ebx
subl %eax, %ebx						# eax has the total written characters, %ebx has remaining characters to read
jne read_loop

function_exit:
movl %ebp, %esp
popl %ebp
ret

function_exit_error:
movl $-1, %eax
jmp function_exit

