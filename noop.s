.globl _start
.section .text
_start:
mov $60, %rax
mov $42, %rdi
syscall
