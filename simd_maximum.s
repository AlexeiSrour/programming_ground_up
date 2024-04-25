#PURPOSE:			This porgram finds the maximum number
#					from a statically assigned array using
#					SIMD intrinsics
#
#					Relevant simd notes:
#					Registers are ymm0 to ymm15
#					Loading into vector register is vmovdqa SRC DEST(ymm-)
#					Shuffling a vector reguester is vpshufd control SRC DEST
#					Doing a permut shuffle in register is vpermd SRC MASK DEST
#					Doing a max vector comparison is vpmaxsd SRC1 SRC2 DEST
#					Moving the lowest lane is vmovd SRC dest (note, it looks as though you're supposed to use xmm, not ymm here


.section .data
unsorted_list:
.long 3,67,34,223,45,75,54,34,246,33,22,11,66,0,243,1,2,3,244
end_list:

.align 32
final_shuffle:
.long 0,4,1,5,2,6,3,7	# This array is used to set a permutation mask

.section .text

.globl _start
_start:

# Find the count of the unsorted list
movq $unsorted_list, %rax;
movq $end_list, %rbx;

subq %rax, %rbx			# rbx contains the length of the list in bytes

# Number of bytes/4 = number of elements in list
# number of elements in list / 8 (length of avx2 vector) = number of avx comparator loops
# number of elements in list % 8 (lenght of avx2 vector) = number of serial loops

# for the timebeing, hardcode the values for nubmer of avx comparator loops and serial loops
# comparator loops = 2
# serial loops = 3

movl $64, %ecx			# number of avx comparator loops (expressed in bytes since indirect 
						# indexed addressing can't have a scale factor of 32 -_-
movl $3, %edx			# number of serial loops

# Initialising all registers for the upcoming loop
movl $0, %eax			# will store the max at the end of a comparator loop
movl $0, %ebx			# will store the true maximum
movl $0, %edi			# edi will keep track of the number of loops (both comparator and serial loops)
start_avx_comparator_loop:
# Loading vector register
vmovdqa unsorted_list(%edi), %ymm0

# The series of shuffles and max comparisons
vpshufd $0b10110001, %ymm0, %ymm1		# 1234 5678 -> 2143 6587
vpmaxsd %ymm0, %ymm1, %ymm0
vpshufd $0b00011011, %ymm0, %ymm1		# 1234 5678 -> 4321 8765
vpmaxsd %ymm0, %ymm1, %ymm0
vmovdqa final_shuffle, %ymm1			# this last shuffle requires special handling to hit all 8 lanes
vpermd %ymm0, %ymm1, %ymm1				# 1234 5678 -> 1526 3648
vpmaxsd %ymm0, %ymm1, %ymm0

vmovd %xmm0, %eax		# Saving the comparator's value to eax

cmpl %eax, %ebx			# Checking comparators value against current highest
cmovl %eax, %ebx		# Conditional move if ebx is less than eax (i.e. save new max value into ebx)


addl $32, %edi
cmpl %edi, %ecx
jne start_avx_comparator_loop

# Falls through to serial comparisons after exhausting all AVX potential
movl $0, %edi			# counter for how many serial loops to do
start_serial_comparison_loop:
movl unsorted_list(%ecx,%edi,4), %eax	# loading the next element, ecx is the offset into array where avx stopped
cmpl %eax, %ebx			# Checking current value against highest saved value
cmovl %eax, %ebx		# Conditional move into ebx if ebx is smaller than eax (i.e. save new max value)

addl $1, %edi
cmpl %edi, %edx			# checking if total number of iterations match the count of iterations required
jne start_serial_comparison_loop

# Fall through once all iterations complete. The highest value will be saved into ebx
# Exit the program

movl $1, %eax			# 1 is the exit() syscall
int $0x80				# 0x80 is the linux kernal syscall interupt handler

