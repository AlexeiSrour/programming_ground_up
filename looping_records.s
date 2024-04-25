# PURPOSE: One of the excercises from the book. Writes 30 identical records to a file

# INPUTS: optional output file (STDOUT default)
# OUTPUT: reads out the contents of the record to the output file (stdout if none provided)

.include "linux.s"
.include "record-def.s"

.section .data

usage_string:
.ascii "usage: looping_records [output]\n"
.equ usage_string_len, . - usage_string

output_file_error:
.ascii "unable to open output file or create output file, not sure how that's possible?\n"
.equ output_file_error_len, . - output_file_error

record1:
.asciz "Bobert"
.equ padding1_name_count, RECORD_MIDDLENAME - (. - record1)
.rept padding1_name_count
.byte 0
.endr

.asciz "Seeing eyer bear"
.equ padding1_middle_count, RECORD_LASTNAME - (. - record1)
.rept padding1_middle_count
.byte 0
.endr

.asciz "Bartlett"
.equ padding1_last_count, RECORD_ADDRESS - (. - record1)
.rept padding1_last_count
.byte 0
.endr

.asciz "4242 S Prarie\nTulsa, OK, 55555"
.equ padding1_address_count, RECORD_AGE - (. - record1)
.rept padding1_address_count
.byte 0
.endr

.long 45

.section .text

.equ LOOPS, 30

.equ ERR_USAGE, 1
.equ ERR_OUTFILE, 2

.globl _start
.equ ST_ARGC, 0
.equ ST_ARGV0, 4
.equ ST_ARGV1, 8
.equ ST_WRITE_FILE, -4
.equ ST_LOOP_COUNT, -8
_start:
movl %esp, %ebp
subl $8, %esp

movl $STDOUT, ST_WRITE_FILE(%ebp) 	# setting up stdout as default output file
movl $LOOPS, ST_LOOP_COUNT(%ebp)

# Check if usage is correct, i.e. 1 or 2 parameters only
movl ST_ARGC(%ebp), %eax
cmpl $2, %eax
je open_file_descriptor
cmpl $1, %eax
je skip_opening_descriptor

# fall through to incorrect usage error, print usage string
pushl $usage_string_len
pushl $usage_string
call write_error_msg
addl $8, %esp

movl $ERR_USAGE, %ebx		# error return value
jmp end_program

# open file descriptor to output files
open_file_descriptor:
movl $SYS_OPEN, %eax
movl ST_ARGV1(%ebp), %ebx
movl $0101, %ecx	# write/truncrate/create
movl $0666, %edx	# magic number

int $LINUX_SYSCALL

movl %eax, ST_WRITE_FILE(%ebp)
cmpl $-1, %eax
jne skip_opening_descriptor

pushl $output_file_error_len
pushl $output_file_error
call write_error_msg
addl $8, %esp

movl $ERR_OUTFILE, %ebx
jmp end_program

skip_opening_descriptor:

# write out to the filedescriptors
pushl ST_WRITE_FILE(%ebp)
pushl $record1
call write_record
addl $4, %esp

movl ST_LOOP_COUNT(%ebp), %eax
decl %eax
cmpl $0, %eax
movl %eax, ST_LOOP_COUNT(%ebp)
jne skip_opening_descriptor

# end program
end_program_success:
movl $0, %ebx
end_program:
movl %ebp, %esp
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
