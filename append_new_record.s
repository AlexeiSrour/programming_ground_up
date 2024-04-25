# This program will allow the user to manually generate a new record and append it to a specified file

# CLI arguments: output file
# inputs: text strings delimited by /0 (eof, ctrl-d in terminal)
# outputs: appends to the specified output file

# dependencies: linux.s for syscalls, record-def.s for definitions, read.s, write.s, count-chars.s

.include "linux.s"
.include "record-def.s"

.section .data

# this will be like a jump table for the various record fields
record_offsets:
.long RECORD_NUM_ELEMENTS
.long RECORD_FIRSTNAME
.long RECORD_MIDDLENAME
.long RECORD_LASTNAME
.long RECORD_ADDRESS
.long RECORD_AGE

record_sizes:
.long RECORD_NUM_ELEMENTS
.long RECORD_MIDDLENAME - RECORD_FIRSTNAME
.long RECORD_LASTNAME - RECORD_MIDDLENAME
.long RECORD_ADDRESS - RECORD_LASTNAME
.long RECORD_AGE - RECORD_ADDRESS
.long RECORD_SIZE - RECORD_AGE

# where the record that will be written out is stored
record_readwrite_buffer:
.comm readwrite_buffer, RECORD_SIZE

usage_string:
.ascii "<program name> output_file\n"
.equ usage_string_len, . - usage_string

file_open_error:
.ascii "unable to open specified file. It must be an already existing file with write permission; did you mispell it?\n"
.equ file_open_error_len, . - file_open_error

reading_error:
.ascii "there was an error reading the input provided for the file element\n"
.equ reading_error_len, . - reading_error

writing_error:
.ascii "there was an error writing out the created record to the provided file\n"
.equ writing_error_len, . - writing_error

.section .bss

.lcomm RECORD_BUFFER, RECORD_SIZE

.section .text
.globl _start

.equ ERR_USAGE, -1
.equ ERR_OPEN, -2
.equ ERR_READ, -3
.equ ERR_WRITE, -4

.equ PAR_ARGV_2, 8
.equ PAR_ARGV_1, 4
.equ PAR_ARGC, 0
.equ ST_WRITEFILE, -4
_start:
movl %esp, %ebp
subl $-4, %esp

# verify command line input is correct
# open the output file
# zero out the record section bss
# read input from stdin (/0 terminated) and save it into the correct section of the buffer for every entry
# write the buffer to the file

# ===============================
# Command Line Verification start
# ===============================

cmpl $2, PAR_ARGC(%ebp)
jne error_incorrect_usage

# ======================
# Opening the file start
# ======================

movl $SYS_OPEN, %eax
movl PAR_ARGV_2(%ebp), %ebx
movl $2, %ecx		# write only, append
movl $0666, %edx	# magic number, idk
int $LINUX_SYSCALL

cmpl $0, %eax
jl error_file_open

movl %eax, ST_WRITEFILE(%ebx)

movl %eax, %ebx
movl $SYS_LSEEK, %eax
movl $0, %ecx
movl $2, %edx
int $LINUX_SYSCALL

# =========================
# Reading record from stdin
# =========================

movl $0, %esi		# loop count, counting number of record fields iterated through
read_new_element:
# setup for reading new element, gets constants from global lookup table
incl %esi
movl record_sizes(,%esi,4), %ecx		# size of the record element
movl record_offsets(,%esi,4), %edx		# offset to read/write into the buffer
addl $readwrite_buffer, %edx			# pointer to actual section in buffer

pushl %ecx
pushl %edx
pushl $STDIN
call read
addl $12, %esp

cmpl $0, %eax			# error testing
jl error_reading_input

pushl $STDOUT
call write_newline
addl $4, %esp

cmpl $RECORD_NUM_ELEMENTS, %esi
jne read_new_element

# ========================
# write record out to file
# ========================

#movl ST_WRITEFILE(%ebp), %eax
movl $3, %eax

pushl $RECORD_SIZE
pushl $readwrite_buffer
pushl %eax
call write
addl $12, %esp

cmpl $0, %eax
jl error_write_file

# =============================
# program successfully executed
# =============================

movl $0, %ebx
jmp program_exit_success

error_incorrect_usage:
pushl $usage_string_len
pushl $usage_string
pushl $STDERR
call write
addl $12, %esp

movl $ERR_USAGE, %ebx
jmp program_exit

error_file_open:
pushl $file_open_error_len
pushl $file_open_error
pushl $STDERR
call write
addl $12, %esp

movl $ERR_OPEN, %ebx
jmp program_exit

error_reading_input:
pushl $reading_error_len
pushl $reading_error
pushl $STDERR
call write
addl $12, %esp

movl $ERR_READ, %ebx
jmp program_exit

error_write_file:
pushl $writing_error_len
pushl $writing_error
pushl $STDERR
call write
addl $12, %esp

movl $ERR_WRITE, %ebx
jmp program_exit

program_exit_success:
program_exit:
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
