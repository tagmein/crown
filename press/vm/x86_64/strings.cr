# String and memory operations

get emit_bss, call '    .lcomm itoa_buffer, 32'

get emit_text, call '# === String Operations ===

# strlen(str=%rdi) -> length in %rax
strlen:
    testq %rdi, %rdi
    jz .strlen_done
    xorq %rax, %rax
.strlen_loop:
    cmpb $0, (%rdi, %rax)
    je .strlen_done
    incq %rax
    jmp .strlen_loop
.strlen_done:
    ret

# strcmp(s1=%rdi, s2=%rsi) -> 0 if equal in %rax
strcmp:
    xorq %rcx, %rcx
.strcmp_loop:
    movb (%rdi, %rcx), %al
    movb (%rsi, %rcx), %dl
    cmpb %dl, %al
    jne .strcmp_diff
    testb %al, %al
    jz .strcmp_equal
    incq %rcx
    jmp .strcmp_loop
.strcmp_equal:
    xorq %rax, %rax
    ret
.strcmp_diff:
    movzbq %al, %rax
    movzbq %dl, %rdx
    subq %rdx, %rax
    ret

# strcpy(dest=%rdi, src=%rsi) -> dest in %rax
strcpy:
    movq %rdi, %rax
    xorq %rcx, %rcx
.strcpy_loop:
    movb (%rsi, %rcx), %dl
    movb %dl, (%rdi, %rcx)
    testb %dl, %dl
    jz .strcpy_done
    incq %rcx
    jmp .strcpy_loop
.strcpy_done:
    ret

# strdup_len(src=%rdi, len=%rsi) -> heap copy in %rax
# Copies len bytes from src to a new heap allocation, null-terminates
strdup_len:
    pushq %rbx
    pushq %r12
    pushq %r13
    movq %rdi, %r12
    movq %rsi, %r13
    leaq 1(%r13), %rdi
    call heap_alloc
    movq %rax, %rbx
    movq %rbx, %rdi
    movq %r12, %rsi
    movq %r13, %rdx
    call memcpy
    movb $0, (%rbx, %r13)
    movq %rbx, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret

# starts_with(str=%rdi, prefix=%rsi, prefix_len=%rdx) -> 1/0 in %rax
starts_with:
    xorq %rcx, %rcx
.sw_loop:
    cmpq %rdx, %rcx
    je .sw_match
    movb (%rdi, %rcx), %al
    cmpb (%rsi, %rcx), %al
    jne .sw_no
    incq %rcx
    jmp .sw_loop
.sw_match:
    movq $1, %rax
    ret
.sw_no:
    xorq %rax, %rax
    ret

# memcpy(dest=%rdi, src=%rsi, len=%rdx)
memcpy:
    xorq %rcx, %rcx
.memcpy_loop:
    cmpq %rdx, %rcx
    je .memcpy_done
    movb (%rsi, %rcx), %al
    movb %al, (%rdi, %rcx)
    incq %rcx
    jmp .memcpy_loop
.memcpy_done:
    ret

# memset(dest=%rdi, byte=%rsi, len=%rdx)
memset:
    xorq %rcx, %rcx
.memset_loop:
    cmpq %rdx, %rcx
    je .memset_done
    movb %sil, (%rdi, %rcx)
    incq %rcx
    jmp .memset_loop
.memset_done:
    ret

# itoa(value=%rdi, buffer=%rsi) -> length in %rax
# Converts integer to decimal string
itoa:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    movq %rdi, %rax
    movq %rsi, %r12
    xorq %r13, %r13
    movq $10, %rbx
    # Handle negative
    testq %rax, %rax
    jns .itoa_pos
    movb $45, (%r12)
    incq %r12
    incq %r14
    negq %rax
.itoa_pos:
    xorq %r14, %r14
    # Handle zero
    testq %rax, %rax
    jnz .itoa_digits
    movb $48, (%r12)
    movb $0, 1(%r12)
    movq $1, %rax
    jmp .itoa_ret
.itoa_digits:
    xorq %rdx, %rdx
    divq %rbx
    addq $48, %rdx
    pushq %rdx
    incq %r13
    testq %rax, %rax
    jnz .itoa_digits
    # Pop digits into buffer
    xorq %rcx, %rcx
.itoa_pop:
    testq %r13, %r13
    jz .itoa_end
    popq %rdx
    movb %dl, (%r12, %rcx)
    incq %rcx
    decq %r13
    jmp .itoa_pop
.itoa_end:
    movb $0, (%r12, %rcx)
    movq %rcx, %rax
.itoa_ret:
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# strstr(haystack=%rdi, needle=%rsi) -> index in %rax (-1 if not found)
strstr:
    pushq %rbx
    pushq %r12
    pushq %r13
    movq %rdi, %r12
    movq %rsi, %r13
    # Get needle length
    movq %rsi, %rdi
    call strlen
    testq %rax, %rax
    jz .ss_zero
    movq %rax, %rbx
    # Search
    xorq %rcx, %rcx
.ss_outer:
    cmpb $0, (%r12, %rcx)
    je .ss_nf
    xorq %rdx, %rdx
.ss_inner:
    cmpq %rbx, %rdx
    je .ss_found
    movb (%r12, %rcx), %al
    testb %al, %al
    jz .ss_nf
    movb (%r13, %rdx), %r8b
    cmpb %r8b, %al
    jne .ss_next
    incq %rcx
    incq %rdx
    jmp .ss_inner
.ss_next:
    subq %rdx, %rcx
    incq %rcx
    jmp .ss_outer
.ss_found:
    subq %rdx, %rcx
    movq %rcx, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret
.ss_nf:
    movq $-1, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret
.ss_zero:
    xorq %rax, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret

# str_ends_with(str=%rdi, suffix=%rsi) -> 1/0 in %rax
str_ends_with:
    pushq %rbx
    pushq %r12
    pushq %r13
    movq %rdi, %r12
    movq %rsi, %r13
    call strlen
    movq %rax, %rbx
    movq %r13, %rdi
    call strlen
    cmpq %rbx, %rax
    jg .sew_no
    movq %rbx, %rcx
    subq %rax, %rcx
    # Compare str+offset with suffix
    xorq %rdx, %rdx
.sew_loop:
    cmpq %rax, %rdx
    je .sew_yes
    movb (%r12, %rcx), %r8b
    movb (%r13, %rdx), %r9b
    cmpb %r9b, %r8b
    jne .sew_no
    incq %rcx
    incq %rdx
    jmp .sew_loop
.sew_yes:
    movq $1, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret
.sew_no:
    xorq %rax, %rax
    popq %r13
    popq %r12
    popq %rbx
    ret

# str_concat(s1=%rdi, s2=%rsi) -> new string in %rax
str_concat:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    movq %rdi, %r12
    movq %rsi, %r13
    call strlen
    movq %rax, %r14
    movq %r13, %rdi
    call strlen
    movq %rax, %rbx
    # Allocate len1 + len2 + 1
    leaq 1(%r14, %rbx), %rdi
    call heap_alloc
    movq %rax, %rcx
    # Copy s1
    movq %rcx, %rdi
    movq %r12, %rsi
    movq %r14, %rdx
    pushq %rcx
    call memcpy
    popq %rcx
    # Copy s2
    leaq (%rcx, %r14), %rdi
    movq %r13, %rsi
    movq %rbx, %rdx
    pushq %rcx
    call memcpy
    popq %rcx
    # Null terminate
    movq %r14, %rax
    addq %rbx, %rax
    movb $0, (%rcx, %rax)
    movq %rcx, %rax
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# strdup(src=%rdi) -> heap copy in %rax
strdup:
    pushq %rbx
    movq %rdi, %rbx
    call strlen
    movq %rax, %rsi
    movq %rbx, %rdi
    call strdup_len
    popq %rbx
    ret'
