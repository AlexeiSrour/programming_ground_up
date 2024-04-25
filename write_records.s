.include "linux.s"
.include "record-def.s"

# NOTE: no include for the read and write record functions, those will be compiled separately and then
#		we inform the linker about them after the fact for where to get the definitions (since they'll
#		be listed in this file so the linker will have to fetch them from elsewhere

.section .data

# For the purposes of demonstration, the records being written will be hardcoded here. In order to ensure
# correct lenghts, each string item will be padded with 0s to the correct length. To this end, the .rept
# directive will be used in conjunction with the .endr

record1:
.asciz "Frederick"
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

record2:
.asciz "Marilyn"
.equ padding2_name_count, RECORD_MIDDLENAME - (. - record2)
.rept padding2_name_count
.byte 0
.endr

.asciz "Nani dafuq you say to me?"
.equ padding2_middle_count, RECORD_LASTNAME - (. - record2)
.rept padding2_middle_count
.byte 0
.endr

.asciz "Taylor"
.equ padding2_last_count, RECORD_ADDRESS - (. - record2)
.rept padding2_last_count
.byte 0
.endr

.asciz "2224 S Johannan St\nChicago, IL 12345"
.equ padding2_address_count, RECORD_AGE - (. - record2)
.rept padding2_address_count
.byte 0
.endr

.long 29

record3:
.asciz "Derrick"
.equ padding3_name_count, RECORD_MIDDLENAME - (. - record3)
.rept padding3_name_count
.byte 0
.endr

.asciz "Konichiwassup"
.equ padding3_middle_count, RECORD_LASTNAME - (. - record3)
.rept padding3_middle_count
.byte 0
.endr

.asciz "McIntire"
.equ padding3_last_count, RECORD_ADDRESS - (. - record3)
.rept padding3_last_count
.byte 0
.endr

.asciz "500 W Oakland\nSan Diego, CA 54331"
.equ padding3_address_count, RECORD_AGE - (. - record3)
.rept padding3_address_count
.byte 0
.endr

.long 36

# This will be the file we write to
filename:
.asciz "test.dat"

.equ ST_FILE_DESCRIPTOR, -4		# local storage on the stack for file descriptor
.section .text
.globl _start
_start:
pushl %ebp
movl %esp, %ebp
subl $4, %esp		# making space on stack for file descriptor

# open new file descriptor
movl $SYS_OPEN, %eax
movl $filename, %ebx
movl $0101, %ecx		# create file if doesn't exist, open for writing
movl $0666, %edx		# magic number for permissions, I think?

int $LINUX_SYSCALL

movl %eax, ST_FILE_DESCRIPTOR(%ebp)

# write to the file descriptor
pushl %eax
pushl $record1
call write_record
addl $8, %esp

pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record2
call write_record
addl $8, %esp

pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record3
call write_record
addl $8, %esp


# close the file descriptor
movl $SYS_CLOSE, %eax
movl ST_FILE_DESCRIPTOR(%ebp), %ebx

int $LINUX_SYSCALL

# End program
movl $0, %ebx

movl %ebp, %esp
popl %ebp

movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
