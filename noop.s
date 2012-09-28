.globl _start
.section .text
_start:
	mov	$60, %rax
;	xor	%rdi, %rdi
	mov     $42, %rdi
	syscall
