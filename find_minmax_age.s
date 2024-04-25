# PURPOSE: This file will loop through the records of a provided input file (default stdin for
#			piping capabilities) and return the min/max as an error code as well as print out
#			to stdout the index of the min/max (cannot print out numbers, idk how to...whoops)

.include "linux.s"
.include "record-def.s"

.section .data

usage_string:
.ascii "usage string: <program name> [input file] [output file]\n"
.equ usage_string_len, . - usage_string

error_opening_input:
.ascii "There was an error opening the provided input file, was there a mispelling?\n"
.equ error_opening_input_len, . - error_opening_input

error_opening_output:
.ascii "There has been an error opening the file desciptor for the output....how??\n"
.equ error_opening_output_len, . - error_opening_output

error_reading_record:
.ascii "Theres been an error in reading the record data. Early EOF before a full record was read.\n"
.ascii "Record files should be a proper multiple of the record size, please make sure your file is correct.\n"
.equ error_reading_record_len, .- error_reading_record


.section .bss
.lcomm RECORD_READWRITE_BUFFER, RECORD_SIZE

.section .text
.globl _start

.equ ERR_USAGE, -1
.equ ERR_INPUT_OPEN, -2
.equ ERR_OUTPUT_OPEN, -3
.equ ERR_READ, -4

.equ ST_ARGV_2, 12
.equ ST_ARGV_1, 8
.equ ST_ARGV_0, 4
.equ ST_ARGC, 0
.equ ST_READ_FILE, -4
.equ ST_WRITE_FILE, -8
.equ ST_MAX_REC_IDX, -12
.equ ST_MAX_REC_AGE, -16
.equ ST_MIN_REC_IDX, -20
.equ ST_MIN_REC_AGE, -24
.equ ST_CURR_REC_IDX, -30
.equ ST_STACK_SIZE, -30
_start:
movl %esp, %ebp
subl $ST_STACK_SIZE, %esp

# Establish read and write file descriptors
# if argc is 1: stdin, stdout | arg is 2: argv1, stdout | argc is 3: argv1, argv2

movl $STDIN, ST_READ_FILE(%ebp)		# set stdin as default input
movl $STDOUT, ST_WRITE_FILE(%ebp)	# set stdout as default output

cmpl $1, ST_ARGC(%ebp)
je read_loop_prologue
cmpl $2, ST_ARGC(%ebp)
je two_input_arg
cmpl $3, ST_ARGC(%ebp)
je three_input_arg

pushl $usage_string_len
pushl $usage_string
call write_error_msg
addl $8, %esp

movl $ERR_USAGE, %ebx
jmp program_exit

two_input_arg:
three_input_arg:
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $0, %ecx		# read only, I think?
movl $0666, %edx	# magic numbers for now
int $LINUX_SYSCALL

cmpl $0, %eax		# error checking
jl input_open_error

movl %eax, ST_READ_FILE(%ebp) # saving new input descriptor

cmpl $2, ST_ARGC(%ebp)	# checking if there were no more inputs
je read_loop_prologue			# early exit as no more new files need to be open

movl $SYS_OPEN, %eax
movl ST_ARGV_2(%ebp), %ebx
movl $0101, %ecx	# write only, truncate, create if doesn't exist
movl $0666, %edx	# magic numbers for now
int $LINUX_SYSCALL

cmpl $0, %eax		# error checking
jl output_open_error

movl %eax, ST_WRITE_FILE(%ebp)
jmp read_loop_prologue

input_open_error:
pushl $error_opening_input_len
pushl $error_opening_input
call write_error_msg
addl $8, %esp

movl $ERR_INPUT_OPEN, %ebx
jmp program_exit

output_open_error:
pushl $error_opening_output_len
pushl $error_opening_output
call write_error_msg
addl $8, %esp

movl $ERR_OUTPUT_OPEN, %ebx
jmp program_exit

# ==================================
# End of reading command line inputs
# ==================================

# ==================================
# Beginning of reading records and finding max age
# ==================================

read_loop_prologue:
# set up local variables
movl $-1, ST_MAX_REC_AGE(%ebp)
movl $-1, ST_MAX_REC_IDX(%ebp)
movl $-1, ST_MIN_REC_IDX(%ebp)
movl $255, ST_MIN_REC_AGE(%ebp)	# slighly different value for min age to simplify comparisons later
movl $-1, ST_CURR_REC_IDX(%ebp)

read_loop:
# Do a (safe) read of the next record input into the buffer
# Compare if the new record is a new min/max
# loop

pushl $RECORD_SIZE
pushl $RECORD_READWRITE_BUFFER
pushl ST_READ_FILE(%ebp)
call read
addl $12, %esp

cmpl $0, %eax		# EOF check
je program_exit_success

cmpl $RECORD_SIZE, %eax	 # make sure full record got read in. only way this won't match is if there's an EOF early
jne record_reading_error

incl ST_CURR_REC_IDX(%ebp)

# Check for the new max
movl RECORD_READWRITE_BUFFER + RECORD_AGE, %eax
cmpl ST_MAX_REC_AGE(%ebp), %eax
jng read_loop_cont

movl %eax, ST_MAX_REC_AGE(%ebp)		# newly read record is the new max
movl ST_CURR_REC_IDX(%ebp), %ebx
movl %ebx, ST_MAX_REC_IDX(%ebp)		# save the index too

read_loop_cont:
# check for the new min
cmpl ST_MIN_REC_AGE(%ebp), %eax
jnl read_loop

movl %eax, ST_MIN_REC_AGE(%ebp)
movl ST_CURR_REC_IDX(%ebp), %ebx
movl %ebx, ST_MIN_REC_IDX(%ebp)
jmp read_loop

record_reading_error:
pushl $error_reading_record_len
pushl $error_reading_record
call write_error_msg
addl $8, %esp

movl $ERR_READ, %ebx
jmp program_exit

# =========================
# End of the business logic of the program
# -------------------------
# Beginning of the program exit
# =========================

program_exit_success:
# min, max, and their indices have been stored on the stack
# time to output one of them as the return code :)

movl ST_MIN_REC_AGE(%ebp), %ebx

program_exit:
movl %ebp, %esp

movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
