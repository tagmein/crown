# Linux x86-64 syscall wrappers and I/O helpers

get emit_bss, call '    .lcomm pipe_fds, 8
    .lcomm date_read_buf, 128'

get emit_data, call 'date_path:
    .asciz "/bin/date"
date_argv0:
    .asciz "date"
date_argv1:
    .asciz "+%-m/%-d/%Y, %-I:%M:%S %p"
date_argv:
    .quad date_argv0
    .quad date_argv1
    .quad 0'

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
    ret

# sys_getcwd(buf=%rdi, size=%rsi) -> buf ptr in %rax (or negative on error)
sys_getcwd:
    movq $79, %rax
    syscall
    ret

# sys_getdents64(fd=%rdi, dirp=%rsi, count=%rdx) -> bytes read in %rax
sys_getdents64:
    movq $217, %rax
    syscall
    ret

# sys_stat(path=%rdi, statbuf=%rsi) -> 0 on success in %rax
sys_stat:
    movq $4, %rax
    syscall
    ret

# sys_lstat(path=%rdi, statbuf=%rsi) -> 0 on success in %rax
sys_lstat:
    movq $6, %rax
    syscall
    ret

# sys_time() -> seconds since epoch in %rax (Linux time(2), syscall 201)
sys_time:
    xorq %rdi, %rdi
    movq $201, %rax
    syscall
    ret

# sys_pipe(fd[2]=%rdi) -> 0 on success
sys_pipe:
    movq $22, %rax
    syscall
    ret

# sys_fork() -> 0 in child, pid in parent
sys_fork:
    movq $57, %rax
    syscall
    ret

# sys_dup2(oldfd=%rdi, newfd=%rsi)
sys_dup2:
    movq $33, %rax
    syscall
    ret

# sys_execve(path=%rdi, argv=%rsi, envp=%rdx)
sys_execve:
    movq $59, %rax
    syscall
    ret

# sys_waitpid(pid=%rdi, status=%rsi, options=%rdx)
sys_waitpid:
    movq $61, %rax
    syscall
    ret

# run_date_string() -> heap-allocated string in %rax (or 0 on failure)
# Runs /bin/date "+%-m/%-d/%Y, %-I:%M:%S %p" and captures output (matches Node toLocaleString)
run_date_string:
    pushq %rbx
    pushq %r12
    pushq %r13
    leaq pipe_fds(%rip), %rdi
    call sys_pipe
    testq %rax, %rax
    js .rds_fail
    call sys_fork
    testq %rax, %rax
    js .rds_fail
    jz .rds_child
    movq %rax, %r12
    movl pipe_fds(%rip), %ebx
    movl pipe_fds+4(%rip), %r13d
    movq %r13, %rdi
    call sys_close
    leaq date_read_buf(%rip), %rsi
    movq $127, %rdx
    movq %rbx, %rdi
    call sys_read
    movq %r12, %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    call sys_waitpid
    movq %rbx, %rdi
    call sys_close
    leaq date_read_buf(%rip), %rdi
    xorq %rcx, %rcx
.rds_find_nl:
    movb (%rdi, %rcx), %al
    testb %al, %al
    jz .rds_strdup
    cmpb $10, %al
    je .rds_zero_nl
    incq %rcx
    cmpq $126, %rcx
    jb .rds_find_nl
.rds_zero_nl:
    movb $0, (%rdi, %rcx)
.rds_strdup:
    call strlen
    movq %rax, %rsi
    leaq date_read_buf(%rip), %rdi
    call strdup_len
    popq %r13
    popq %r12
    popq %rbx
    ret
.rds_child:
    movl pipe_fds+4(%rip), %edi
    movq $1, %rsi
    call sys_dup2
    movl pipe_fds(%rip), %edi
    call sys_close
    movl pipe_fds+4(%rip), %edi
    call sys_close
    leaq date_path(%rip), %rdi
    leaq date_argv(%rip), %rsi
    movq saved_envp(%rip), %rdx
    call sys_execve
    movq $60, %rax
    movq $1, %rdi
    syscall
.rds_fail:
    xorq %rax, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret

# print_stderr(str=%rdi) - print null-terminated string to stderr
print_stderr:
    pushq %rbx
    movq %rdi, %rbx
    call strlen
    movq %rbx, %rsi
    movq %rax, %rdx
    movq $2, %rdi
    movq $1, %rax
    syscall
    popq %rbx
    ret'
