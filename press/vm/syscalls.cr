# Linux x86-64 syscall wrappers and I/O helpers

get emit_text, call '# === Syscall Wrappers ===

# sys_write(fd=%rdi, buf=%rsi, len=%rdx) -> bytes written in %rax
sys_write:
    movq $1, %rax
    syscall
    ret

# sys_read(fd=%rdi, buf=%rsi, len=%rdx) -> bytes read in %rax
sys_read:
    xorq %rax, %rax
    syscall
    ret

# sys_open(path=%rdi, flags=%rsi, mode=%rdx) -> fd in %rax
sys_open:
    movq $2, %rax
    syscall
    ret

# sys_close(fd=%rdi) -> result in %rax
sys_close:
    movq $3, %rax
    syscall
    ret

# sys_brk(addr=%rdi) -> new brk in %rax
sys_brk:
    movq $12, %rax
    syscall
    ret

# sys_exit(code=%rdi) - does not return
sys_exit:
    movq $60, %rax
    syscall

# print_cstring(str=%rdi) - print null-terminated string to stdout
print_cstring:
    pushq %rbx
    movq %rdi, %rbx
    call strlen
    movq %rbx, %rsi
    movq %rax, %rdx
    movq $1, %rdi
    movq $1, %rax
    syscall
    popq %rbx
    ret

# print_newline - print a newline to stdout
print_newline:
    leaq newline_char(%rip), %rsi
    movq $1, %rdx
    movq $1, %rdi
    movq $1, %rax
    syscall
    ret

# print_number(value=%rdi) - print integer to stdout
print_number:
    pushq %rbx
    subq $32, %rsp
    movq %rsp, %rsi
    movq %rdi, %rbx
    movq %rbx, %rdi
    movq %rsp, %rsi
    call itoa
    movq %rsp, %rdi
    call print_cstring
    addq $32, %rsp
    popq %rbx
    ret'
