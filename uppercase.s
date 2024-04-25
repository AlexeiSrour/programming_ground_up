#PURPOSE:		This program converts an input file
#				to an ouput file with all letters
#				converted to uppercase
#
#PROCESSING:	1) Open the input file
#				2) Open the output file
#				3) While we're not tat the end of the input file
#					a) read part of file into our memory buffer
#					b) go through each byte of memory
#						if the byte is a lower-case letter,
#						convert it to uppercase
#					c) write the memory buffer to output file

.section .data

##### CONSTANTS #####

# system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# options for SYS_OPEN syscall
.equ O_RDONLY, 0
.equ O_CREATE_WRONGLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# syscall interrupts
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0
.equ NUMBER_ARGUMENTS, 2

.section .bss
#Buffer - this is where the data is loaded into
#			from the data file and written from
#			into the output file. This shuold
#			never exceed 16,000 for various
#			reasons.
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8	# 4 bytes fits one file descriptor, i.e. this magic number will be used to reserve enough space on stack for file desciptors
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0		# number of arguments
.equ ST_ARGV_0, 4	# name of program
.equ ST_ARGV_1, 8	# input file name
.equ ST_ARGV_2, 12	# output file name

.globl _start
_start:

# Reserve space on stack for file descriptors
movl %esp, %ebp
subl $ST_SIZE_RESERVE, %esp

# Opening the files
movl $SYS_OPEN, %eax		# open file descriptor syscall
movl ST_ARGV_1(%ebp), %ebx	# pointer to the file name
movl $O_RDONLY, %ecx		# read/write/create flags
movl $0666, %edx			# file permissions, magic number for now
int $LINUX_SYSCALL

movl %eax, ST_FD_IN(%ebp)

movl $SYS_OPEN, %eax		# open file descriptor syscall
movl ST_ARGV_2(%ebp), %ebx	# pointer to the file name
movl $O_CREATE_WRONGLY_TRUNC, %ecx		# read/write/create flags
movl $0666, %edx			# file permissions, magic number for now
int $LINUX_SYSCALL

movl %eax, ST_FD_OUT(%ebp)

# Begin main loop
read_loop_begin:
movl $SYS_READ, %eax
movl ST_FD_IN(%ebp), %ebx
movl $BUFFER_DATA, %ecx
movl $BUFFER_SIZE, %edx
int $LINUX_SYSCALL

# check if end of file reached
cmpl $END_OF_FILE, %eax
je read_loop_end

# Convert block to uppercase
pushl $BUFFER_DATA
pushl %eax		# %eax currently stores the number of bytes put into buffer
call convert_to_upper
popl %eax		# get the size back into %eax after function call (register will have been thrashed during function call)
addl $4, %esp

# Write the block out to the output file
movl %eax, %edx			# since %eax currently holds the size of the buffer in bytes and we'll be replacing it soon
movl $SYS_WRITE, %eax
movl ST_FD_OUT(%ebp), %ebx
movl $BUFFER_DATA, %ecx
int $LINUX_SYSCALL

# Restart the loop
jmp read_loop_begin

read_loop_end:

# Close the file descriptors
movl $SYS_CLOSE, %eax
movl ST_FD_OUT(%ebp), %ebx
int $LINUX_SYSCALL

movl $SYS_CLOSE, %eax
movl ST_FD_IN(%ebp), %ebx
int $LINUX_SYSCALL

# restore the stack?
movl %ebp, %esp
popl %ebp

# Exit
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

#PURPOSE:	This function acually does the
#			conversion to upper case for a block
#
#INPUT:		The first parameter is the location
#			of the block of memory to convert
#			The second parameter is the length
#			of that buffer in bytes
#
#OUTPUT:	This function overwrites the current
#			buffer witht he upper -casified version.
#
#VARIABLES:	%eax - beginning of the buffer
#			%ebx - length of the buffer
#			%edi - current buffer offset
#			%cl - Current byte being examined
#				(lower byte of %ecx -> %ch, %cl) (like how eax can be split into ah and al)

### CONSTANTS ###
.equ LOWER_CASE_A, 'a'
.equ LOWER_CASE_Z, 'z'
.equ UPPER_CONVERSION, 'A' - 'a'

### STACK STUFFS(?) ###
.equ ST_BUFFER_LEN, 8	# length of the buffer
.equ ST_BUFFER, 12		# actual buffer

.type convert_to_upper @function
convert_to_upper:
pushl %ebp
movl %esp, %ebp

movl ST_BUFFER(%ebp), %eax
movl ST_BUFFER_LEN(%ebp), %ebx
movl $0, %edi

# if a buffer of 0 size has been given, just leave
cmpl $0, %ebx
je convert_loop_end

# otherwise, begin the function
convert_loop:
movb (%eax,%edi,1), %cl			# Load the current byte

cmpb $LOWER_CASE_A, %cl			# compare if it comes after letter 'a'
jl increment_and_reloop			# if not, move on to next byte, otherwise fall through

cmpb $LOWER_CASE_Z, %cl			# compare if it comes before letter 'z'
jg increment_and_reloop			# if not, move on to next byte, otherwise fall through

addb $UPPER_CONVERSION, %cl		# byte must be between a-z, therefore add constant to make it A-Z
movb %cl, (%eax,%edi,1)			# write it back to the buffer

increment_and_reloop:
incl %edi						# increment to the next byte
cmpl %edi, %ebx					# check to make sure end of buffer hasn't been reached
jne convert_loop				# restart the loop as long as bytes remain

convert_loop_end:
movl %ebp, %esp
popl %ebp
ret
