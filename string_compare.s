# General purpose function to compare two strings

# dependancies: none
# input: string1 pointer, string2 pointer, length to compare
# output: 1 if the same, 0 if different

.type string_compare, @function
.globl string_compare

.equ PAR_LEN, 16
.equ PAR_STR2, 12
.equ PAR_STR1, 8
.equ ST_OUTPUT, -4
string_compare:
pushl %ebp
movl %esp, %ebp
subl $4, %esp

movl $0, ST_OUTPUT(%ebp)	# initialising the return value,(false until proven otherwise)
movl PAR_LEN(%ebp), %esi	# the counter
movl PAR_STR2(%ebp), %edx	# string 2 offset
movl PAR_STR1(%ebp), %ecx	# string 1 offset

comp_loop:
decl %esi
movb (%ecx,%esi,1), %al
cmpb (%edx,%esi,1), %al

jne end_function	# break out of comparison loop once differing letters found

cmpl $0, %esi
jne comp_loop		# continue the loop until completely checked all letters

movl $1, ST_OUTPUT(%ebp)	# save the return value

end_function:
movl ST_OUTPUT(%ebp), %eax

movl %ebp, %esp
popl %ebp
ret
