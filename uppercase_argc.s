# Purpose: This program is the very last exercise from chapter 5. It will either print out to stdout or
# a separately specified file depending on number of arguements passed in

.section .data

input_open_failed_msg:
.ascii "Failed to open provided input file, has there been a mispelling?\n"
.equ input_open_failed_msg_len, . - input_open_failed_msg

output_open_failed_msg:
.ascii "Failed to open provided output file...idk how this would be possible? Check error code and google\n"
.equ output_open_failed_msg_len, . - output_open_failed_msg

too_many_arguments_error_msg:
.ascii "Too many arguments have been provided to the program\n"
.equ too_many_arguments_error_msg_len, . - too_many_arguments_error_msg

usage_string:
.ascii "Usage is <program name> [input file name] [output file name]\n"
.equ usage_string_len, . - usage_string

input_read_failed_msg:
.ascii "Failed to read in stream from input file\n"
.equ input_read_failed_msg_len, . - input_read_failed_msg

output_write_failed_msg:
.ascii "Failed to write to output file\n"
.equ output_write_failed_msg_len, . - output_write_failed_msg

.section .bss

.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

# Linux Syscalls
.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6

.equ LINUX_SYSCALL, 0x80

# options (argument 3) for OPEN syscall
.equ O_RDONLY, 0
.equ O_CREATE_WRONGLY_TRUNCATE, 03101	# i.e. create file if it isn't there, and not to append but wipe file clean

.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ ST_ARGC, 4
.equ ST_ARGV_0, 8	# this is the name of the executable
.equ ST_ARGV_1, 12	# this will be the argument to the input file (if provided)
.equ ST_ARGV_2, 16	# this will be the argument to the output file (if provided)

.equ ST_LOCAL_STORAGE, 12	# enough room to stack allocate input and output file descriptors
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ERROR_CODE, -12
.equ ST_BYTES_READ, -12	# error code and written bytes are aliased

.globl _start
_start:
pushl %ebp
movl %esp, %ebp
subl $ST_LOCAL_STORAGE, %esp	# allocating space for input file descriptor and output file descriptor

movl ST_ARGC(%ebp), %eax
cmpl $1, %eax					# check if no extra arguements provided
jne arguments_check_2

movl $STDIN, ST_FD_IN(%ebp)		# make input and output the console
movl $STDOUT, ST_FD_OUT(%ebp)
jmp argument_check_end

arguments_check_2:
cmpl $2, %eax					# check if an input file has been provided
jne arguments_check_3

# open a file desciptor for the input file and check for success
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $O_RDONLY, %ecx
movl $0666, %edx				# magic number for full read/write/execute permission on file, I think

int $LINUX_SYSCALL

#check for error or success
cmpl $0, %eax
jge inputfile_opened_successfully

# on error, print out error message and close program
movl %eax, ST_ERROR_CODE(%ebp)	# save the error code to stack for later use
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
movl $input_open_failed_msg, %ecx
movl $input_open_failed_msg_len, %edx

int $LINUX_SYSCALL

movl ST_ERROR_CODE(%ebp), %ebx	# will be returning the error code on program exit
jmp end_program

inputfile_opened_successfully:
movl %eax, ST_FD_IN(%ebp)		# save in the input file to the stack
movl $STDOUT, ST_FD_OUT(%ebp)	# put the output file as being stdout
jmp argument_check_end

arguments_check_3:
cmpl $3, %eax
jne arguments_error	

# open a file desciptor for the input file and check for success
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $O_RDONLY, %ecx
movl $0666, %edx				# magic number for full read/write/execute permission on file, I think

int $LINUX_SYSCALL

#check for error or success
cmpl $0, %eax
jge argument_continue_check_3

# on error, print out error message and close program
movl %eax, ST_ERROR_CODE(%ebp)	# save the error code to stack for later use
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
movl $input_open_failed_msg, %ecx
movl $input_open_failed_msg_len, %edx

int $LINUX_SYSCALL

movl ST_ERROR_CODE(%ebp), %ebx	# will be returning the error code on program exit
jmp end_program

argument_continue_check_3:
# open a file desciptor for the output and check for success
movl %eax, ST_FD_IN(%ebp)		# save current input descriptor
movl $SYS_OPEN, %eax
movl ST_ARGV_2(%ebp), %ebx
movl $O_CREATE_WRONGLY_TRUNCATE, %ecx
movl $0666, %edx				# magic number for full read/write/execute permission on file, I think

int $LINUX_SYSCALL

#check for error or success
cmpl $0, %eax
jge outputfile_opened_successfully

# on error, print out error message and close program
movl %eax, ST_ERROR_CODE(%ebp)	# save the error code to stack for later use
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
movl $output_open_failed_msg, %ecx
movl $output_open_failed_msg_len, %edx

int $LINUX_SYSCALL

movl ST_ERROR_CODE(%ebp), %ebx	# will be returning the error code on program exit
jmp end_program

outputfile_opened_successfully:
movl %eax, ST_FD_OUT(%ebp)		# save output to the stack (input already there)
jmp argument_check_end

arguments_error:
# write to stdout that too many arguments have been provided (and the usage string too)

movl $SYS_WRITE, %eax
movl $STDOUT, %ebx
movl $too_many_arguments_error_msg, %ecx
movl $too_many_arguments_error_msg_len, %edx

int $LINUX_SYSCALL

movl $SYS_WRITE, %eax
movl $STDOUT, %ebx
movl $usage_string, %ecx
movl $usage_string_len, %edx

int $LINUX_SYSCALL

movl $-1, %ebx
jmp end_program

argument_check_end:
# By this point in the program, we have fully validated that all file descriptors are open and ready to go
# At this point, we are to read in to a buffer from input, capitalise the buffer, then write to the output from buffer
# additional error checks will have to be performed during reading and writing

# Read the input into the buffer
movl $SYS_READ, %eax
movl ST_FD_IN(%ebp), %ebx
movl $BUFFER_DATA, %ecx
movl $BUFFER_SIZE, %edx

int $LINUX_SYSCALL

# error checking
cmpl $0, %eax
je end_program_success  # we've reached input end, time to close the program
jg continue_writing		# no error, so continue to next phase

movl %eax, ST_ERROR_CODE(%ebp)
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
movl $input_read_failed_msg, %ecx
movl $input_read_failed_msg_len, %edx

int $LINUX_SYSCALL

jmp end_program

continue_writing:
# Time to capitalise the buffer
pushl %eax
pushl $BUFFER_DATA
call to_upper
addl $4, %esp
popl %eax				# restore length of buffer into %eax

# Time to write out our data to the output
writing_loop:			# label here in case the full write doesn't complete
movl %eax, ST_BYTES_READ(%ebp)	# save total read bytes to the stack for later usage
movl %eax, %edx			# total read is currently held in %eax
movl $SYS_WRITE, %eax
movl ST_FD_OUT(%ebp), %ebx
movl $BUFFER_DATA, %ecx

int $LINUX_SYSCALL

cmpl $0, %eax
jge validate_write_completed

movl %eax, ST_ERROR_CODE(%ebp)
movl $SYS_WRITE, %eax
movl $STDERR, %ebx
movl $output_write_failed_msg, %ecx
movl $output_write_failed_msg_len, %edx

int $LINUX_SYSCALL

movl ST_ERROR_CODE(%ebp), %eax
jmp end_program


validate_write_completed:
cmpl ST_BYTES_READ(%ebp), %eax
je argument_check_end	# time to loop over again and reread the next section

subl ST_BYTES_READ(%ebp), %eax	# %eax holds the remainind number of bytes to be read
jmp writing_loop

end_program_success:
#clean up and close the program with a success code (0)
movl $SYS_CLOSE, %eax
movl ST_FD_OUT(%ebp), %ebx
int $LINUX_SYSCALL

movl $SYS_CLOSE, %eax
movl ST_FD_IN(%ebp), %ebx
int $LINUX_SYSCALL

movl $0, %ebx

end_program:	# label for all other emergency closes such as critical errors
movl %ebp, %esp
popl %ebp

movl $SYS_EXIT, %eax
int $LINUX_SYSCALL


.equ ST_BUFFER_DATA, 8	# first parameter is a pointer to the buffer to capitalise
.equ ST_BUFFER_LEN, 12	# second parameter is the length of the buffer
.equ UPPER_CONVERSION_CONST, 'A' - 'a'	# add this constant to any lowercase letter to turn it uppercase
.equ LOWER_CASE_BOTTOM, 'a'
.equ LOWER_CASE_UPPER, 'z'
.type to_upper @function
to_upper:
pushl %ebp
movl %esp, %ebp

movl ST_BUFFER_DATA(%ebp), %ecx	# will hold the offset
movl ST_BUFFER_LEN(%ebp), %edx
movl $0, %eax			# zeroing out eax as the lower portion will hold our buffer

conversion_loop:
cmpl $0, %edx
je conversion_loop_end	# finished reading through the buffer
decl %edx
movb (%ecx,%edx,1), %al	# al will hold the current byte (i.e. letter)

cmp $LOWER_CASE_BOTTOM, %al
jl conversion_loop		# is not lower case letter, can read in next letter

cmp $LOWER_CASE_UPPER, %al
jg conversion_loop		# is not lower case letter, can read in next letter

addb $UPPER_CONVERSION_CONST, %al	# convert letter to upper case
movb %al, (%ecx,%edx,1)				# then write it back into the buffer
jmp conversion_loop

conversion_loop_end:

movl %ebp, %esp
popl %ebp
ret
