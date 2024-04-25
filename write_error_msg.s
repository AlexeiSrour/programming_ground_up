# PURPOSE: Multi use generic function to print out to STDERR

# Dependancies: none, completely self contained
# inputs: pointer to message buffer, length of message
# ouputs: number of characters written (should always equal length)

# Extra notes: the function will fully write out to STDERR, no partial writes

.equ SYS_WRITE, 4		# system call number
.equ LINUX_SYSCALL, 0x80 # linux syscall trap handler
.equ STDERR, 2			# output file descriptor

.type write_error_msg, @function
.globl write_error_msg

.equ ST_MSG_LEN, 12		# parameter 2
.equ ST_MSG_BUF, 8		# parameter 1
.equ ST_WRITTEN_CHARS, -4	# local storage to track total written out
.equ ST_CURRENT_CHAR, -8	# local storage to point at current letter in buffer
write_error_msg:
pushl %ebp
movl %esp, %ebp
subl $8, %esp

movl $0, ST_WRITTEN_CHARS(%ebp)
movl ST_MSG_BUF(%ebp), %ecx
movl %ecx, ST_CURRENT_CHAR(%ebp)
movl ST_MSG_LEN(%ebp), %ebx

write_loop:
movl ST_CURRENT_CHAR(%ebp), %ecx
movl %ebx, %edx
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
int $LINUX_SYSCALL

addl %eax, ST_WRITTEN_CHARS(%ebp)
addl %eax, ST_CURRENT_CHAR(%ebp)

movl ST_WRITTEN_CHARS(%ebp), %eax
movl ST_MSG_LEN(%ebp), %ebx
subl %eax, %ebx						# eax has the total written characters, %ebx has remaining characters to write
jne write_loop

movl %ebp, %esp
popl %ebp
ret
