.include "linux.s"
.include "record-def.s"

.section .data

read_file:
.asciz "test.dat"

write_file:
.asciz "modified.dat"

.section .bss
.lcomm RECORD_BUFFER, RECORD_SIZE

.section .text

.equ ST_READ_FILEDES, -4
.equ ST_WRITE_FILEDES, -8
.globl _start
_start:
movl %esp, %ebp
sub $8, %esp			# space for file descriptors

# Start by opening relevant file descriptors

movl $SYS_OPEN, %eax
movl $read_file, %ebx
movl $0, %ecx			# read only
movl $0666, %edx

int $LINUX_SYSCALL

movl %eax, ST_READ_FILEDES(%ebp)

movl $SYS_OPEN, %eax
movl $write_file, %ebx
movl $0101, %ecx		# create file if it doesn't exist, open for writing
movl $0666, %edx

int $LINUX_SYSCALL

movl %eax, ST_WRITE_FILEDES(%ebp)

# Read in the input file into a buffer
# modify the age segment
# write out the full record out into the new file descriptor
# repeat the process until we run out of records to read

read_write_loop:

# Read in the file
pushl ST_READ_FILEDES(%ebp)
pushl $RECORD_BUFFER
call read_record
addl $4, %esp

cmp $RECORD_SIZE, %eax
jne read_write_loop_end	# if full record hasn't been read, either end of file or an error, so exit program

# Modify the age
pushl $(RECORD_BUFFER + RECORD_AGE) 
call increment_age
addl $4, %esp

# Write out the thing
pushl ST_WRITE_FILEDES(%ebp)
pushl $RECORD_BUFFER
call write_record
addl $8, %esp

jmp read_write_loop

read_write_loop_end:

# Even bother closing file descriptors?

movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
