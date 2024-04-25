# Excersize from the end of chapter 5 of the book
# writes out "hey diddle diddle" to a file called heynow.txt
# I've also added extra error checking

.section .data

message:
.ascii "Hey diddle diddle!\n"
.equ message_len, . - message

file_name:
.asciz "heynow.txt"	 # File names are always relative to the current working directory, no extra slashes required

succ_msg:
.ascii "syscall returned without error\n"
.equ succ_msg_len, . - succ_msg

fail_msg:
.ascii "syscall returned with error\n"
.equ fail_msg_len, . - fail_msg

.section .bss

.equ FD_SIZE, 4
.lcomm FD_OUTPUT, FD_SIZE		# only an output to write to, no input taken from anywhere

.section .text

.equ SYS_EXIT, 1
.equ SYS_WRITE, 4
.equ SYS_OPENFD, 5
.equ SYS_CLOSE, 6
.equ LINUX_SYSCALL, 0x80

.equ WRITE_OPT, 03101
.equ WRITE_PERM, 0666

.globl _start
_start:
pushl %ebp
movl %esp, %ebp

# open/create new file descriptor for file heynow.txt
movl $SYS_OPENFD, %eax
movl $file_name, %ebx
movl $WRITE_OPT, %ecx
movl $WRITE_PERM, %edx
int $LINUX_SYSCALL

# Do error checking on the file descriptor here

# write message out to the file
movl %eax, %ebx			# put file descriptor into correct place
movl $SYS_WRITE, %eax
movl $message, %ecx
movl $message_len, %edx
int $LINUX_SYSCALL

# close file descriptor and end program
movl $SYS_CLOSE, %eax
# no need to move the file descriptor into %ebx as it's already there and %ebx is a saved register
int $LINUX_SYSCALL

# do some error checking here on the close value (0 on succ, -1 on fail)
cmpl $0, %eax
je success
movl $fail_msg, %ecx
movl $fail_msg_len, %edx
jmp end_block
success:
movl $succ_msg, %ecx
movl $succ_msg_len, %edx
end_block:
movl $SYS_WRITE, %eax
movl $1, %ebx
int $LINUX_SYSCALL

movl %ebp, %esp
popl %ebp

movl $SYS_EXIT, %eax
movl $message_len, %ebx
int $LINUX_SYSCALL

