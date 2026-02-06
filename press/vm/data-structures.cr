# Data structure operations: maps (for Crown scope) and arrays
# Map: linear-scan key-value store on heap
# Array: dynamic element store on heap
#
# Map layout (3080 bytes):
#   [length: 8] [entry0: key(8)+type(8)+val(8)] ... [entry127]
#
# Array layout (4112 bytes):
#   [length: 8] [elem0: type(8)+val(8)] ... [elem255]

get emit_text, call '# === Data Structures ===

# vm_map_new() -> map pointer in %rax
vm_map_new:
    pushq %rbx
    movq $3080, %rdi
    call heap_alloc_zero
    popq %rbx
    ret

# vm_map_set(map=%rdi, key=%rsi, type=%rdx, value=%rcx)
vm_map_set:
    # Guard: skip if key is NULL
    testq %rsi, %rsi
    jz .ms_null_key
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    movq %rdi, %r12
    movq %rsi, %r13
    movq %rdx, %r14
    movq %rcx, %r15
    movq (%r12), %rbx
    xorq %rcx, %rcx
.ms_search:
    cmpq %rbx, %rcx
    jge .ms_append
    movq %rcx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq (%rdi, %rax), %rsi
    pushq %rcx
    pushq %rax
    movq %r13, %rdi
    call strcmp
    movq %rax, %r8              # save strcmp result
    popq %rax
    popq %rcx
    testq %r8, %r8
    jz .ms_update
    incq %rcx
    jmp .ms_search
.ms_update:
    movq %rcx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq %r14, 8(%rdi, %rax)
    movq %r15, 16(%rdi, %rax)
    jmp .ms_done
.ms_append:
    movq %rbx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq %r13, (%rdi, %rax)
    movq %r14, 8(%rdi, %rax)
    movq %r15, 16(%rdi, %rax)
    incq %rbx
    movq %rbx, (%r12)
.ms_done:
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret
.ms_null_key:
    ret

# vm_map_get(map=%rdi, key=%rsi) -> type in %rax, value in %rdx
# Returns type=0 (undefined) if not found
vm_map_get:
    # Guard: return undefined if key is NULL
    testq %rsi, %rsi
    jz .mg_null_key
    pushq %rbx
    pushq %r12
    pushq %r13
    movq %rdi, %r12
    movq %rsi, %r13
    movq (%r12), %rbx
    xorq %rcx, %rcx
.mg_search:
    cmpq %rbx, %rcx
    jge .mg_notfound
    movq %rcx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq (%rdi, %rax), %rsi
    pushq %rcx
    pushq %rax
    movq %r13, %rdi
    call strcmp
    movq %rax, %r8              # save strcmp result
    popq %rax
    popq %rcx
    testq %r8, %r8
    jz .mg_found
    incq %rcx
    jmp .mg_search
.mg_found:
    movq %rcx, %rbx
    imulq $24, %rbx
    leaq 8(%r12), %rdi
    movq 8(%rdi, %rbx), %rax
    movq 16(%rdi, %rbx), %rdx
    popq %r13
    popq %r12
    popq %rbx
    ret
.mg_notfound:
    xorq %rax, %rax
    xorq %rdx, %rdx
    popq %r13
    popq %r12
    popq %rbx
    ret
.mg_null_key:
    xorq %rax, %rax
    xorq %rdx, %rdx
    ret

# vm_map_has(map=%rdi, key=%rsi) -> 1/0 in %rax
vm_map_has:
    call vm_map_get
    testq %rax, %rax
    jz .mh_no
    movq $1, %rax
    ret
.mh_no:
    xorq %rax, %rax
    ret

# vm_array_new() -> array pointer in %rax
vm_array_new:
    pushq %rbx
    movq $4112, %rdi
    call heap_alloc_zero
    popq %rbx
    ret

# vm_array_push(array=%rdi, type=%rsi, value=%rdx)
vm_array_push:
    movq (%rdi), %rax
    cmpq $255, %rax
    jg .ap_full
    shlq $4, %rax
    leaq 8(%rdi, %rax), %rcx
    movq %rsi, (%rcx)
    movq %rdx, 8(%rcx)
    movq (%rdi), %rax
    incq %rax
    movq %rax, (%rdi)
    ret
.ap_full:
    ret

# vm_array_get(array=%rdi, index=%rsi) -> type in %rax, value in %rdx
vm_array_get:
    movq (%rdi), %rax
    cmpq %rax, %rsi
    jge .ag_oob
    movq %rsi, %rax
    shlq $4, %rax
    leaq 8(%rdi, %rax), %rcx
    movq (%rcx), %rax
    movq 8(%rcx), %rdx
    ret
.ag_oob:
    xorq %rax, %rax
    xorq %rdx, %rdx
    ret

# vm_array_length(array=%rdi) -> length in %rax
vm_array_length:
    movq (%rdi), %rax
    ret'
