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
    # Guard: skip if map is NULL (avoids segfault)
    testq %rdi, %rdi
    jz .ms_null_key
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
    # Guard: return undefined if map is NULL (avoids segfault)
    testq %rdi, %rdi
    jz .mg_null_key
    # Guard: return undefined if key is NULL or not inside heap (avoids strcmp on integer-as-key)
    testq %rsi, %rsi
    jz .mg_null_key
    movq heap_start(%rip), %r8
    movq heap_current(%rip), %r9
    cmpq %r8, %rsi
    jb .mg_null_key
    cmpq %r9, %rsi
    jae .mg_null_key
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
    # Cap index so we never read past map buffer (127 entries max)
    cmpq $128, %rcx
    jge .mg_notfound
    movq %rcx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq (%rdi, %rax), %rsi
    # Skip entries with key not in heap (avoid strcmp on integer-as-key)
    testq %rsi, %rsi
    jz .mg_skip_entry
    movq heap_start(%rip), %r8
    movq heap_current(%rip), %r9
    cmpq %r8, %rsi
    jb .mg_skip_entry
    cmpq %r9, %rsi
    jae .mg_skip_entry
    pushq %rcx
    pushq %rax
    movq %r13, %rdi
    call strcmp
    movq %rax, %r8              # save strcmp result
    popq %rax
    popq %rcx
    testq %r8, %r8
    jz .mg_found
.mg_skip_entry:
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
    testq %rdi, %rdi
    jz .ag_oob
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
    testq %rdi, %rdi
    jz .al_zero
    movq (%rdi), %rax
    ret
.al_zero:
    xorq %rax, %rax
    ret

# vm_array_set(array=%rdi, index=%rsi, type=%rdx, value=%rcx)
vm_array_set:
    movq (%rdi), %rax
    cmpq %rax, %rsi
    jge .as_oob
    movq %rsi, %rax
    shlq $4, %rax
    leaq 8(%rdi, %rax), %r8
    movq %rdx, (%r8)
    movq %rcx, 8(%r8)
.as_oob:
    ret

# vm_map_length(map=%rdi) -> length in %rax
vm_map_length:
    testq %rdi, %rdi
    jz .ml_zero
    movq (%rdi), %rax
    ret
.ml_zero:
    xorq %rax, %rax
    ret

# vm_map_key_at(map=%rdi, index=%rsi) -> key ptr in %rax
vm_map_key_at:
    movq %rsi, %rax
    imulq $24, %rax
    movq 8(%rdi, %rax), %rax
    ret

# vm_map_type_at(map=%rdi, index=%rsi) -> type in %rax
vm_map_type_at:
    movq %rsi, %rax
    imulq $24, %rax
    movq 16(%rdi, %rax), %rax
    ret

# vm_map_val_at(map=%rdi, index=%rsi) -> value in %rax
vm_map_val_at:
    movq %rsi, %rax
    imulq $24, %rax
    movq 24(%rdi, %rax), %rax
    ret

# vm_map_delete(map=%rdi, key=%rsi) - remove entry, shift remaining
vm_map_delete:
    testq %rsi, %rsi
    jz .mdel_done
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    movq %rdi, %r12
    movq %rsi, %r13
    movq (%r12), %rbx
    xorq %rcx, %rcx
.mdel_search:
    cmpq %rbx, %rcx
    jge .mdel_nf
    movq %rcx, %rax
    imulq $24, %rax
    leaq 8(%r12), %rdi
    movq (%rdi, %rax), %rsi
    pushq %rcx
    pushq %rax
    movq %r13, %rdi
    call strcmp
    movq %rax, %r8
    popq %rax
    popq %rcx
    testq %r8, %r8
    jz .mdel_found
    incq %rcx
    jmp .mdel_search
.mdel_found:
    movq %rcx, %r14
    leaq 8(%r12), %rdi
.mdel_shift:
    movq %r14, %rax
    incq %rax
    cmpq %rbx, %rax
    jge .mdel_shifted
    movq %r14, %rcx
    imulq $24, %rcx
    movq %rax, %rdx
    imulq $24, %rdx
    movq (%rdi, %rdx), %rsi
    movq %rsi, (%rdi, %rcx)
    movq 8(%rdi, %rdx), %rsi
    movq %rsi, 8(%rdi, %rcx)
    movq 16(%rdi, %rdx), %rsi
    movq %rsi, 16(%rdi, %rcx)
    incq %r14
    jmp .mdel_shift
.mdel_shifted:
    decq %rbx
    movq %rbx, (%r12)
.mdel_nf:
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
.mdel_done:
    ret

# vm_map_copy(dest=%rdi, src=%rsi) - copy all entries from src to dest
vm_map_copy:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    movq %rdi, %r12
    movq %rsi, %r13
    movq (%r13), %r14
    xorq %rbx, %rbx
.mc_loop:
    cmpq %r14, %rbx
    jge .mc_done
    movq %rbx, %rax
    imulq $24, %rax
    leaq 8(%r13), %rcx
    movq (%rcx, %rax), %rsi
    movq 8(%rcx, %rax), %rdx
    movq 16(%rcx, %rax), %rcx
    movq %r12, %rdi
    pushq %rbx
    call vm_map_set
    popq %rbx
    incq %rbx
    jmp .mc_loop
.mc_done:
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret'
