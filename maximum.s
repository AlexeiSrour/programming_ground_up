# PURPOSE this is an exercise from chapter 4 of the book, making functions for finding the max of a list

.section .data
list_1:
.long 1,2,3,4,5,6,6,7,8,1,2,43,123,235,45,3,6
endlist_1:

list_2:
.long 46,46,14,23,155,234,34
endlist_2:

list_3:
.long 151,233,123,69,73,33,52,71,89,124,222,61,67
endlist_3:

.section .text
.globl _start
_start:
pushl $endlist_1
pushl $list_1
call find_max
addl $8, %esp

pushl $endlist_2
pushl $list_2
call find_max
addl $8, %esp

pushl $endlist_3
pushl $list_3
call find_max
addl $8, %esp

movl %eax, %ebx			# Save the last max found as return value to exit() syscall

movl $1, %eax			# $1 will be the linux exit() syscall
int $0x80				# $0x80 is the linux syscall handler

# find_max returns the maximum value from an array. It takes a start pointer and an end pointer as arguements

.type find_max @function
find_max:
pushl %ebp
movl %esp, %ebp

movl 8(%ebp), %edi		# start of list 
movl 12(%ebp), %esi		# end of the list
movl $0, %ecx			# counter for dereferencing purposes

movl $0, %eax			# current max value will be stored in %eax
loop:
movl (%edi), %ebx	# current value in list
cmpl %ebx, %eax		# is this the max
cmovl %ebx, %eax	# save %ebx if %eax is too small

addl $4, %edi		# increment the pointer by 4 bytes (length of int32)
cmpl %edi, %esi	# are we pointing at the end of the list
jne loop

movl %esp, %ebp
popl %ebp
ret
