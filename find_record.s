# this file will find any records whose first name matches up to the giben string input

# inputs: record file, string to find
# output: none

.include "linux.s"
.include "record-def.s"

.data

usage_string:
.ascii "usage: <program name> record_file search_string\n"
.equ usage_string_len, . - usage_string

open_error:
.ascii "unable to find file, please make sure it is an existing record file with read permissions\n"
.equ open_error_len, . - open_error

read_error:
.ascii "unexpected issue reading a record from the file, is the file descriptor readable?\n"
.equ read_error_len, . - read_error

 /*	the below data structure is a list of pointers to each error string and their corresponding lengths
    it has been prepared this way as a test and to simplify the error handling code,
	i.e., all the data you need is in this array and is indexed by the error code */
error_array:
.long usage_string_len, usage_string, open_error_len, open_error, read_error_len, read_error
.equ error_array_stride, 8

.bss

.lcomm RECORD_BUFFER, RECORD_SIZE

.text
.globl _start

.equ ERR_USAGE, 1
.equ ERR_OPEN, 2
.equ ERR_READ, 3

.equ PAR_ARGV_2, 12		# search string
.equ PAR_ARGV_1, 8		# record file
.equ PAR_ARGV_0, 4		# program name
.equ PAR_ARGC, 0

.equ ST_RECORD_FILEDES, -4
.equ ST_STR_LEN, -8
_start:
movl %esp, %ebp
subl $8, %esp

# ====================
# Read in command line
# ====================

cmpl $3, PAR_ARGC(%ebp)
movl $ERR_USAGE, %ebx
jne error_handler

# ===============
# Open input file
# ===============

movl PAR_ARGV_1(%ebp), %ebx
movl $SYS_OPEN, %eax
movl $0, %ecx			# read only, I think
movl $0666, %edx		# magic numbers, idk what for
int $LINUX_SYSCALL

cmpl $0, %eax
movl $ERR_OPEN, %ebx
jl error_handler

movl %eax, ST_RECORD_FILEDES(%ebp)	# saving the file des

# ========================
# Search records and print
# ========================

/* read record into bss section
   find length of input string
   compare record name and input string
   if same, write record to stdout
   loop
*/

pushl PAR_ARGV_2(%ebp)
call count_chars
addl $4, %esp

movl %eax, ST_STR_LEN(%ebp)

read_compare_loop:
# read in the next record
pushl $RECORD_SIZE
pushl $RECORD_BUFFER
pushl ST_RECORD_FILEDES(%ebp)
call read
addl $12, %esp

cmp $0, %eax	# exit on eof
je program_exit_success
movl $ERR_READ, %ebx	# error on failed read
jl error_handler

# compare the first name and the string
pushl ST_STR_LEN(%ebp)
pushl $RECORD_BUFFER + RECORD_FIRSTNAME
pushl PAR_ARGV_2(%ebp)
call string_compare
addl $12, %esp

cmpl $0, %eax		#checking if the strings are different
je read_compare_loop

# if the same, print the record
pushl $RECORD_BUFFER
call print_record
addl $4, %esp

jmp read_compare_loop

# ==============
# Error handling
# ==============

error_handler:
decl %ebx			# ebx will actually let us index into the global error array for print string and lenght
movl $0, %ecx
pushl error_array(%ecx,%ebx,error_array_stride)		# length from the error array
addl $4, %ecx
pushl error_array(%ecx,%ebx,error_array_stride)		# actual char pointer to error string
pushl $STDERR
call write

addl $4, %esp
incl %ebx
jmp program_exit

# ============
# Program exit
# ============
program_exit_success:
movl $0, %ebx
program_exit:
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
