# PURPOSE: Incrememnts the age of a provided record
#
# INPUT: Pointer to the age variable
# OUTPUT: n/a I suppose?

.type increment_age, @function
.global increment_age

.equ ST_RECORD_AGE, 8
increment_age:
pushl %ebp
movl %esp, %ebp

# read the age into ebx
movl ST_RECORD_AGE(%ebp), %eax
movl (%eax), %ebx

incl %ebx

# write it back out
movl %ebx, (%eax)

movl %ebp, %esp
popl %ebp
ret
