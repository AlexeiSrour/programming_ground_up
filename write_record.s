.include "linux.s"			# for linux syscall definitions and other conveniences
.include "record-def.s"		# Definition of record fields and record size

# PURPOSE:			This funciton writes a record to the given file descriptor (from the correct buffer)
#
# INPUT:			The file descriptor and the buffer
#
# OUTPUT:			This funciton produces a status code that matches the write syscall code

# STACK LOCAL VARIABLES
.equ ST_WRITE_BUFFER, 8
.equ ST_FILEDES, 12

.section .text
.globl write_record
.type write_record, @function
write_record:
pushl %ebp
movl %esp, %ebp

pushl %ebx			# %ebx will end up clobbered (due to a syscall) so must be restored by function end

# calling the write syscall
movl $SYS_WRITE, %eax
movl ST_FILEDES(%ebp), %ebx
movl ST_WRITE_BUFFER(%ebp), %ecx
movl $RECORD_SIZE, %edx

int $LINUX_SYSCALL

# NOTE: For correctness, one would repeat the write if it didn't fully complete, but for the sake of brevity
#		we'll assume the write always functions correctly

popl %ebx

movl %esp, %ebp
popl %ebp
ret
