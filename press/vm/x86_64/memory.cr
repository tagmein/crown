# Heap memory allocator (brk-based)

get emit_bss, call '    .lcomm heap_start, 8
    .lcomm heap_current, 8
    .lcomm heap_large_count, 8'

get emit_data, call 'heap_fail_msg:
    .asciz "Error: heap allocation failed\\n"
heap_fail_prefix:
    .asciz "Error: heap allocation failed (requested "
heap_fail_suffix:
    .asciz " bytes, heap used: "
heap_fail_large_prefix:
    .asciz " bytes, large (>=256KB) allocs: "
heap_fail_used_suffix:
    .asciz ")\\n"'

get emit_text, call '# === Memory Management ===

# heap_init - initialize heap via brk(0)
heap_init:
    xorq %rdi, %rdi
    call sys_brk
    movq %rax, heap_start(%rip)
    movq %rax, heap_current(%rip)
    ret

# heap_alloc(size=%rdi) -> address in %rax
heap_alloc:
    pushq %rbx
    pushq %r12
    # Align size to 8 bytes
    addq $7, %rdi
    andq $-8, %rdi
    movq %rdi, %r12
    # Count large allocs (>=256KB) for leak debugging
    cmpq $262144, %r12
    jb .heap_alloc_skip_large
    movq heap_large_count(%rip), %rcx
    incq %rcx
    movq %rcx, heap_large_count(%rip)
.heap_alloc_skip_large:
    # Get current heap top
    movq heap_current(%rip), %rbx
    # Calculate new top
    leaq (%rbx, %r12), %rdi
    call sys_brk
    # Check success (rax >= requested)
    leaq (%rbx, %r12), %rcx
    cmpq %rcx, %rax
    jl .heap_alloc_fail
    # Update heap_current
    movq %rcx, heap_current(%rip)
    # Return old top (allocated block start)
    movq %rbx, %rax
    popq %r12
    popq %rbx
    ret

.heap_alloc_fail:
    leaq heap_fail_prefix(%rip), %rdi
    call print_cstring
    movq %r12, %rdi
    call print_number
    leaq heap_fail_suffix(%rip), %rdi
    call print_cstring
    movq heap_current(%rip), %rdi
    subq heap_start(%rip), %rdi
    call print_number
    leaq heap_fail_large_prefix(%rip), %rdi
    call print_cstring
    movq heap_large_count(%rip), %rdi
    call print_number
    leaq heap_fail_used_suffix(%rip), %rdi
    call print_cstring
    movq $1, %rdi
    call sys_exit

# heap_alloc_zero(size=%rdi) -> zeroed address in %rax
heap_alloc_zero:
    pushq %rbx
    pushq %r12
    movq %rdi, %r12
    call heap_alloc
    movq %rax, %rbx
    # Zero the memory
    movq %rbx, %rdi
    xorq %rsi, %rsi
    movq %r12, %rdx
    call memset
    movq %rbx, %rax
    popq %r12
    popq %rbx
    ret'
