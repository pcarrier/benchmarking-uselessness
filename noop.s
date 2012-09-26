.globl _start
.section .text
_start:
	mov	$60, %rax
	mov	$0, %rdi
	syscall
