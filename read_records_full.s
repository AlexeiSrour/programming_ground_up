.include "linux.s"
.include "record-def.s"

.section .data

.section .bss
.lcomm RECORD_BUFFER, RECORD_SIZE

.section .text

.equ ST_ARGV_2, 8
.equ ST_ARGV_1, 4
.equ ST_ARGC, 0
.equ ST_READ_FILEDES, -4
.equ ST_WRITE_FILEDES, -8
.globl _start
_start:
movl %esp, %ebp
sub $8, %esp			# space for file descriptors

movl ST_ARGC(%ebp), %eax
cmpl $2, %eax
jne read_write_loop_end

# Start by opening relevant file descriptors

movl $SYS_OPEN, %eax
movl ST_ARGV_2(%ebp), %ebx
movl $0, %ecx			# read only
movl $0666, %edx

int $LINUX_SYSCALL

movl %eax, ST_READ_FILEDES(%ebp)
movl $STDOUT, ST_WRITE_FILEDES(%ebp)

# Read in the input file into a buffer
# count the length of the lastname field so we can
# write out the last name to the output file descriptor (add new line too)
# repeat the process until we run out of records to read

pushl ST_WRITE_FILEDES(%ebp)
call write_separator
addl $4, %esp

read_write_loop:

# Read in the file
pushl ST_READ_FILEDES(%ebp)
pushl $RECORD_BUFFER
call read_record
addl $4, %esp

cmp $0, %eax
je read_write_loop_end	# end of file has been reach and we may now exit

# Count the lenght of the string to print
pushl $RECORD_BUFFER+RECORD_FIRSTNAME
call count_chars
addl $4, %esp

# Write out the thing
movl %eax, %edx
movl $SYS_WRITE, %eax
movl ST_WRITE_FILEDES(%ebp), %ebx
movl $RECORD_BUFFER+RECORD_FIRSTNAME, %ecx

int $LINUX_SYSCALL

# don't forget new line
pushl ST_WRITE_FILEDES(%ebp)
call write_newline
addl $4, %esp

# Count the lenght of the string to print
pushl $RECORD_BUFFER+RECORD_MIDDLENAME
call count_chars
addl $4, %esp

# Write out the thing
movl %eax, %edx
movl $SYS_WRITE, %eax
movl ST_WRITE_FILEDES(%ebp), %ebx
movl $RECORD_BUFFER+RECORD_MIDDLENAME, %ecx

int $LINUX_SYSCALL

# don't forget new line
pushl ST_WRITE_FILEDES(%ebp)
call write_newline
addl $4, %esp

# Count the lenght of the string to print
pushl $RECORD_BUFFER+RECORD_LASTNAME
call count_chars
addl $4, %esp

# Write out the thing
movl %eax, %edx
movl $SYS_WRITE, %eax
movl ST_WRITE_FILEDES(%ebp), %ebx
movl $RECORD_BUFFER+RECORD_LASTNAME, %ecx

int $LINUX_SYSCALL

# don't forget new line
pushl ST_WRITE_FILEDES(%ebp)
call write_newline
addl $4, %esp

# Count the lenght of the string to print
pushl $RECORD_BUFFER+RECORD_ADDRESS
call count_chars
addl $4, %esp

# Write out the thing
movl %eax, %edx
movl $SYS_WRITE, %eax
movl ST_WRITE_FILEDES(%ebp), %ebx
movl $RECORD_BUFFER+RECORD_ADDRESS, %ecx

int $LINUX_SYSCALL

# don't forget new line
pushl ST_WRITE_FILEDES(%ebp)
call write_separator
addl $4, %esp

jmp read_write_loop

read_write_loop_end:

# Even bother closing file descriptors?
pushl ST_WRITE_FILEDES(%ebp)
call write_newline
addl $4, %esp

movl $SYS_EXIT, %eax
int $LINUX_SYSCALL

