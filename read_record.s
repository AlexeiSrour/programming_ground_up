.include "record-def.s"		# definition for record size and fields
.include "linux.s"		# syscall number definitions and other linux conveniences

# PURPOSE:		This function reads a record from the file desciptor provided
#
# INPUT:		The file descriptor and the buffer to save to
#
# OUTPUT:		This funciton writes the data of the record to the buffer and returns the write status code
#				i.e. number of bytes read.... this sounds prone to error in instances where the read is
#				successful, but doesn't fully complete the read

# STACK LOCAL VARIABLES
.equ ST_READ_BUFFER, 8		# input parameter number 1
.equ ST_FILEDES, 12			# input parameter number 2

.section .text
.globl read_record
.type read_record, @function
read_record:
push %ebp
movl %esp, %ebp

pushl %ebx				# ebx will be clobbered, so must be restored by end of function

# calling the read syscall
movl $SYS_READ, %eax
movl ST_FILEDES(%ebp), %ebx
movl ST_READ_BUFFER(%ebp), %ecx
movl $RECORD_SIZE, %edx

int $LINUX_SYSCALL

# NOTE: For correctness, one would check to see if the full read completed successfully, but for the sake of
#		brevity, we'll assume no errors and full reads always happen. Might be an interesting project to include

popl %ebx

movl %ebp, %esp
popl %ebp
ret
