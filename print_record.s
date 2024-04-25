# Purpose: this is a function for the purposes of printing a full record sans age to terminal

# dependancies: record-def.s, count-char.s
# input: pointer to the full record buffer, no partial stuffs
# output: pretty prints the record

.include "linux.s"
.include "record-def.s"

.data

newline: .ascii "\n"
.equ newline_len, . - newline

delimiter: .ascii "========================\n"
.equ delimiter_len, . - delimiter

.text
.globl print_record
.type print_record, @function

.equ PAR_RECBUFFER, 8
.equ ST_STR_LOCATION, -4
print_record:
pushl %ebp
movl %esp, %ebp
subl $4, %esp

movl $SYS_WRITE, %eax					# print the delimiter
movl $STDOUT, %ebx
movl $delimiter, %ecx
movl $delimiter_len, %edx
int $LINUX_SYSCALL

movl $0, %esi							# loop initialisation
field_print_loop:
movl RECORD_OFFSETS(,%esi,4), %ecx		# current offset into record
movl PAR_RECBUFFER(%ebp), %edx			# where teh buffer is located
lea (%edx,%ecx,1), %eax					# adddress of the string in buffer

movl %eax, ST_STR_LOCATION(%ebp)		# saving address for later

pushl %eax								# counting length of string to print
call count_chars
addl $4, %esp

movl %eax, %edx							# printing out to console
movl ST_STR_LOCATION(%ebp), %ecx
movl $SYS_WRITE, %eax
movl $STDOUT, %ebx
int $LINUX_SYSCALL

movl $SYS_WRITE, %eax					# printing a newline
movl $STDOUT, %ebx
movl $newline, %ecx
movl $newline_len, %edx
int $LINUX_SYSCALL

incl %esi
cmpl $RECORD_NUM_ELEMENTS, %esi
jl field_print_loop

movl $SYS_WRITE, %eax					# print the delimiter
movl $STDOUT, %ebx
movl $delimiter, %ecx
movl $delimiter_len, %edx
int $LINUX_SYSCALL

movl %ebp, %esp
popl %ebp
ret
