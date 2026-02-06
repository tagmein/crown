.section .data
heap_fail_msg:
    .asciz "Error: heap allocation failed\n"
# CA command name strings for dispatch
ca_cmd_value:       .asciz "value"
ca_cmd_log:         .asciz "log"
ca_cmd_print:       .asciz "print"
ca_cmd_reg_set:     .asciz "register_set"
ca_cmd_reg_get:     .asciz "register_get"
ca_cmd_reg_to:      .asciz "register_to"
ca_cmd_add:         .asciz "add"
ca_cmd_subtract:    .asciz "subtract"
ca_cmd_multiply:    .asciz "multiply"
ca_cmd_divide:      .asciz "divide"
ca_cmd_compare_eq:  .asciz "compare_eq"
ca_cmd_compare_lt:  .asciz "compare_lt"
ca_cmd_compare_gt:  .asciz "compare_gt"
ca_cmd_label:       .asciz "label"
ca_cmd_jump:        .asciz "jump"
ca_cmd_jump_if:     .asciz "jump_if"
ca_cmd_jump_if_not: .asciz "jump_if_not"
ca_cmd_define:      .asciz "define"
ca_cmd_invoke:      .asciz "invoke"
ca_cmd_return:      .asciz "return"
ca_cmd_string:      .asciz "string"
ca_cmd_string_len:  .asciz "string_length"
ca_cmd_push:        .asciz "push"
ca_cmd_pop:         .asciz "pop"
ca_cmd_sys_exit:    .asciz "sys_exit"
ca_cmd_file_read:   .asciz "file_read"
ca_cmd_map_new:      .asciz "map_new"
ca_cmd_map_set:      .asciz "map_set"
ca_cmd_map_get:      .asciz "map_get"
ca_cmd_map_has:      .asciz "map_has"
ca_cmd_map_setd:     .asciz "map_set_dynamic"
ca_cmd_map_getd:     .asciz "map_get_dynamic"
ca_cmd_array_new:    .asciz "array_new"
ca_cmd_array_push:   .asciz "array_push"
ca_cmd_array_get:    .asciz "array_get"
ca_cmd_array_len:    .asciz "array_length"
ca_cmd_array_set:    .asciz "array_set"
ca_cmd_tree_parse:   .asciz "tree_parse"
ca_cmd_tree_type:    .asciz "tree_type"
ca_cmd_tree_value:   .asciz "tree_value"
ca_cmd_tree_adv:     .asciz "tree_advance"
ca_cmd_tree_save:    .asciz "tree_save"
ca_cmd_tree_rest:    .asciz "tree_restore"
ca_cmd_tree_skip:    .asciz "tree_skip_block"
ca_cmd_tree_pos:     .asciz "tree_position"
ca_cmd_tree_seek:    .asciz "tree_seek"
ca_cmd_str_cmp:      .asciz "string_compare"
ca_cmd_str_concat:   .asciz "string_concat"
ca_cmd_str_charat:   .asciz "string_char_at"
ca_cmd_str_starts:   .asciz "string_starts_with"
ca_cmd_str_append:   .asciz "string_append_char"
ca_cmd_str_new:      .asciz "string_new"
ca_cmd_str_finish:   .asciz "string_finish"
ca_cmd_str_appbuf:   .asciz "string_append_buf"
ca_cmd_typeof:       .asciz "typeof"
ca_cmd_to_string:    .asciz "to_string"
ca_cmd_to_number:    .asciz "to_number"
ca_cmd_args_count:   .asciz "args_count"
ca_cmd_args_get:     .asciz "args_get"
ca_cmd_print_nl:     .asciz "print_newline"
ca_cmd_print_char:   .asciz "print_char"
ca_type_undefined:   .asciz "undefined"
ca_type_null:        .asciz "null"
ca_type_number:      .asciz "number"
ca_type_string:      .asciz "string"
ca_type_boolean:     .asciz "boolean"
ca_type_array:       .asciz "array"
ca_type_map:         .asciz "map"
ca_type_function:    .asciz "function"
ca_squote:           .byte 39, 0
ca_unknown_msg:      .asciz "Unknown CA command: "
ca_space:            .asciz " "
banner:
    .ascii "crown-x86_64 v0.1.0\n"
    .set banner_len, . - banner
usage_msg:
    .ascii "Usage: crown-x86_64 [file.ca ...] [-- args...]\n"
    .set usage_len, . - usage_msg
dashdash:
    .asciz "--"
newline_char:
    .byte 10
err_no_files:
    .asciz "Error: no .ca files specified\n"
err_open_fail:
    .asciz "Error: cannot open file\n"
opt_zero_short:
    .asciz "-0"
opt_zero_long:
    .asciz "--zero"
default_engine:
    .asciz "engines/a.ca"
default_repl:
    .asciz "repl.cr"

.section .bss
    .lcomm itoa_buffer, 32
    .lcomm heap_start, 8
    .lcomm heap_current, 8
    .lcomm token_buf, 4096
    .lcomm token_len, 8
    .lcomm parse_state, 8
    .lcomm parse_tree, 262144
    .lcomm parse_node_count, 8
    .lcomm parse_output_ptr, 8
    .lcomm parse_has_tokens, 8
    .lcomm cr_parse_tree, 262144
    .lcomm cr_node_count, 8
    .lcomm vm_regs, 4096
    .lcomm vm_cur_type, 8
    .lcomm vm_cur_val, 8
    .lcomm vm_comp_flag, 8
    .lcomm vm_ip, 8
    .lcomm vm_labels, 8192
    .lcomm vm_label_count, 8
    .lcomm vm_procs, 8192
    .lcomm vm_proc_count, 8
    .lcomm vm_call_stack, 4096
    .lcomm vm_call_sp, 8
    .lcomm vm_val_stack, 8192
    .lcomm vm_val_sp, 8
    .lcomm vm_jumped, 8
    .lcomm tree_cursor, 8
    .lcomm tree_cursor_stack, 8192
    .lcomm tree_cursor_sp, 8
    .lcomm str_build_ptr, 8
    .lcomm str_build_len, 8
    .lcomm saved_rsp, 8
    .lcomm ca_files, 2048
    .lcomm ca_file_count, 8
    .lcomm rt_args, 2048
    .lcomm rt_args_count, 8
    .lcomm file_buffer, 65536
    .lcomm file_size, 8
    .lcomm banner_suppress, 8

.section .text
# === Syscall Wrappers ===

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
# === String Operations ===

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
# === Memory Management ===

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
    leaq heap_fail_msg(%rip), %rdi
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
    ret
# === Data Structures ===

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
    ret
# === CrownAssembly Parser ===

# parse_ca(input=%rdi, length=%rsi) - parse into parse_tree
parse_ca:
    leaq parse_tree(%rip), %rdx
    call parse_common
    movq %rax, parse_node_count(%rip)
    ret

# parse_cr(input=%rdi, length=%rsi) - parse into cr_parse_tree
parse_cr:
    leaq cr_parse_tree(%rip), %rdx
    call parse_common
    movq %rax, cr_node_count(%rip)
    ret

# parse_common(input=%rdi, length=%rsi, output=%rdx) -> node count in %rax
parse_common:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq %rdi, %r12                # r12 = input buffer
    movq %rsi, %r13                # r13 = input length
    xorq %r14, %r14                # r14 = current position
    movq %rdx, %r15                # r15 = output pointer
    pushq %rdx                     # save initial output ptr

    # Initialize state
    movq $0, parse_state(%rip)     # INITIAL
    movq $0, token_len(%rip)
    movq $0, parse_has_tokens(%rip)

    # Emit implicit top-level BLOCK_START
    movq $1, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15

.pc_loop:
    cmpq %r13, %r14
    jge .pc_end

    movzbq (%r12, %r14), %rax     # current char
    incq %r14

    # Dispatch on state
    movq parse_state(%rip), %rbx
    testq %rbx, %rbx
    jz .st_initial
    cmpq $1, %rbx
    je .st_string
    cmpq $2, %rbx
    je .st_escape
    cmpq $3, %rbx
    je .st_comment
    jmp .pc_loop

# --- INITIAL state ---
.st_initial:
    cmpb $32, %al
    je .ini_space
    cmpb $9, %al
    je .ini_space
    cmpb $10, %al
    je .ini_newline
    cmpb $13, %al
    je .pc_loop
    cmpb $44, %al
    je .ini_newline
    cmpb $35, %al
    je .ini_comment
    cmpb $39, %al
    je .ini_string
    cmpb $91, %al
    je .ini_block_start
    cmpb $93, %al
    je .ini_block_end
    cmpb $40, %al
    je .ini_macro_start
    cmpb $41, %al
    je .ini_macro_end
    # Default: append char to token
    movq token_len(%rip), %rcx
    leaq token_buf(%rip), %rbx
    movb %al, (%rbx, %rcx)
    incq %rcx
    movq %rcx, token_len(%rip)
    jmp .pc_loop

.ini_space:
    call pc_flush_token
    jmp .pc_loop

.ini_newline:
    call pc_flush_token
    call pc_flush_stmt
    jmp .pc_loop

.ini_comment:
    call pc_flush_token
    call pc_flush_stmt
    movq $3, parse_state(%rip)
    jmp .pc_loop

.ini_string:
    call pc_flush_token
    movq $0, token_len(%rip)
    movq $1, parse_state(%rip)
    jmp .pc_loop

.ini_block_start:
    call pc_flush_token
    # Block is inline within the statement (do NOT flush stmt)
    movq $1, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    movq $1, parse_has_tokens(%rip)
    jmp .pc_loop

.ini_block_end:
    call pc_flush_token
    call pc_flush_stmt             # flush last statement inside block
    movq $2, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    movq $1, parse_has_tokens(%rip)
    jmp .pc_loop

.ini_macro_start:
    call pc_flush_token
    movq $6, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    movq $1, parse_has_tokens(%rip)
    jmp .pc_loop

.ini_macro_end:
    call pc_flush_token
    call pc_flush_stmt
    movq $7, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    movq $1, parse_has_tokens(%rip)
    jmp .pc_loop

# --- STRING state ---
.st_string:
    cmpb $92, %al
    je .str_escape
    cmpb $39, %al
    je .str_end
    # Regular char
    movq token_len(%rip), %rcx
    leaq token_buf(%rip), %rbx
    movb %al, (%rbx, %rcx)
    incq %rcx
    movq %rcx, token_len(%rip)
    jmp .pc_loop

.str_escape:
    movq $2, parse_state(%rip)
    jmp .pc_loop

.str_end:
    # Emit string token (even if empty)
    movq token_len(%rip), %rsi
    leaq token_buf(%rip), %rdi
    call strdup_len
    movq $5, (%r15)
    movq %rax, 8(%r15)
    addq $16, %r15
    movq $0, token_len(%rip)
    movq $1, parse_has_tokens(%rip)
    movq $0, parse_state(%rip)
    jmp .pc_loop

# --- ESCAPE state ---
.st_escape:
    cmpb $92, %al
    je .esc_backslash
    cmpb $39, %al
    je .esc_quote
    # Other char: append as-is, state stays ESCAPE (matches Crown behavior)
    movq token_len(%rip), %rcx
    leaq token_buf(%rip), %rbx
    movb %al, (%rbx, %rcx)
    incq %rcx
    movq %rcx, token_len(%rip)
    jmp .pc_loop

.esc_backslash:
    movq token_len(%rip), %rcx
    leaq token_buf(%rip), %rbx
    movb $92, (%rbx, %rcx)
    incq %rcx
    movq %rcx, token_len(%rip)
    movq $1, parse_state(%rip)
    jmp .pc_loop

.esc_quote:
    movq token_len(%rip), %rcx
    leaq token_buf(%rip), %rbx
    movb $39, (%rbx, %rcx)
    incq %rcx
    movq %rcx, token_len(%rip)
    movq $1, parse_state(%rip)
    jmp .pc_loop

# --- COMMENT state ---
.st_comment:
    cmpb $10, %al
    jne .pc_loop
    movq $0, parse_state(%rip)
    jmp .pc_loop

# --- End of input ---
.pc_end:
    call pc_flush_token
    call pc_flush_stmt
    # Close top-level block
    movq $2, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    # END marker
    movq $0, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15

    # Calculate node count: (final_ptr - initial_ptr) / 16
    popq %rax                      # initial output ptr
    subq %rax, %r15                # r15 = bytes written
    shrq $4, %r15                  # divide by 16 = node count
    movq %r15, %rax                # return in rax
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# pc_flush_token - if token_buf has content, emit TOKEN_WORD node
pc_flush_token:
    movq token_len(%rip), %rsi
    testq %rsi, %rsi
    jz .pft_done
    leaq token_buf(%rip), %rdi
    call strdup_len
    movq $4, (%r15)
    movq %rax, 8(%r15)
    addq $16, %r15
    movq $0, token_len(%rip)
    movq $1, parse_has_tokens(%rip)
.pft_done:
    ret

# pc_flush_stmt - emit STMT_END if tokens were emitted since last boundary
pc_flush_stmt:
    movq parse_has_tokens(%rip), %rax
    testq %rax, %rax
    jz .pfs_done
    movq $3, (%r15)
    movq $0, 8(%r15)
    addq $16, %r15
    movq $0, parse_has_tokens(%rip)
.pfs_done:
    ret
# === CrownAssembly VM ===

# vm_init - initialize VM state
vm_init:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    movq $0, vm_comp_flag(%rip)
    movq $0, vm_label_count(%rip)
    movq $0, vm_proc_count(%rip)
    movq $0, vm_call_sp(%rip)
    movq $0, vm_val_sp(%rip)
    movq $0, vm_jumped(%rip)
    ret

# vm_run - interpret the parsed CA program in parse_tree
vm_run:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    leaq parse_tree(%rip), %r12    # r12 = tree base
    addq $16, %r12                 # skip initial BLOCK_START
    movq %r12, %r13                # r13 = current node pointer

    # First pass: collect labels and procedure definitions
    call vm_collect_labels

    # Reset to start
    movq %r12, %r13

.vm_loop:
    movq (%r13), %rax              # node type
    testq %rax, %rax
    jz .vm_really_done             # END marker

    cmpq $2, %rax                  # BLOCK_END
    je .vm_block_end

    cmpq $3, %rax                  # STMT_END - skip
    je .vm_skip_node

    cmpq $4, %rax                  # TOKEN_WORD (command)
    je .vm_exec_stmt
    cmpq $5, %rax                  # TOKEN_STRING (command)
    je .vm_exec_stmt

    cmpq $1, %rax                  # BLOCK_START - skip block
    je .vm_skip_block

    # Other node types - skip
.vm_skip_node:
    addq $16, %r13
    jmp .vm_loop

.vm_block_end:
    addq $16, %r13
    # Check if we are in a procedure call
    movq vm_call_sp(%rip), %rax
    testq %rax, %rax
    jz .vm_really_done             # top-level BLOCK_END = done
    # Implicit return from procedure
    decq %rax
    movq %rax, vm_call_sp(%rip)
    leaq vm_call_stack(%rip), %rdx
    movq (%rdx, %rax, 8), %r13
    jmp .vm_loop

.vm_skip_block:
    # Skip nested block (find matching BLOCK_END)
    addq $16, %r13
    movq $1, %rcx                  # nesting depth
.vm_sb_loop:
    movq (%r13), %rax
    addq $16, %r13
    cmpq $1, %rax
    jne .vm_sb_not_start
    incq %rcx
    jmp .vm_sb_loop
.vm_sb_not_start:
    cmpq $2, %rax
    jne .vm_sb_loop
    decq %rcx
    jnz .vm_sb_loop
    jmp .vm_loop

.vm_exec_stmt:
    # r13 points to first token of statement (the command)
    movq 8(%r13), %rdi             # command name string
    addq $16, %r13                 # advance past command token

    # Dispatch command
    movq $0, vm_jumped(%rip)
    call vm_dispatch

    # If a jump/invoke changed r13, go directly to vm_loop
    movq vm_jumped(%rip), %rax
    testq %rax, %rax
    jnz .vm_did_jump

    # Normal: skip to end of statement (handling nested blocks)
.vm_skip_to_stmt_end:
    movq (%r13), %rax
    cmpq $3, %rax                  # STMT_END
    je .vm_past_stmt
    cmpq $0, %rax                  # END
    je .vm_really_done
    cmpq $2, %rax                  # BLOCK_END (should not happen normally)
    je .vm_block_end
    cmpq $1, %rax                  # BLOCK_START - skip nested block
    jne .vm_sse_next
    # Skip nested block within statement
    addq $16, %r13
    movq $1, %rcx
.vm_sse_skip_block:
    movq (%r13), %rax
    addq $16, %r13
    cmpq $1, %rax
    jne .vm_sse_sb_not_start
    incq %rcx
    jmp .vm_sse_skip_block
.vm_sse_sb_not_start:
    cmpq $2, %rax
    jne .vm_sse_skip_block
    decq %rcx
    jnz .vm_sse_skip_block
    jmp .vm_skip_to_stmt_end
.vm_sse_next:
    addq $16, %r13
    jmp .vm_skip_to_stmt_end

.vm_past_stmt:
    addq $16, %r13                 # skip STMT_END
    jmp .vm_loop

.vm_did_jump:
    movq $0, vm_jumped(%rip)
    jmp .vm_loop

.vm_really_done:
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# vm_dispatch(cmd=%rdi) - dispatch a CA command
# r13 points to the args (tokens after command, before STMT_END)
vm_dispatch:
    pushq %rbx
    movq %rdi, %rbx               # save command name

    # --- value ---
    leaq ca_cmd_value(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_value

    # --- log ---
    leaq ca_cmd_log(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_log

    # --- print ---
    leaq ca_cmd_print(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_print

    # --- register_set ---
    leaq ca_cmd_reg_set(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_reg_set

    # --- register_get ---
    leaq ca_cmd_reg_get(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_reg_get

    # --- register_to ---
    leaq ca_cmd_reg_to(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_reg_to

    # --- add ---
    leaq ca_cmd_add(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_add

    # --- subtract ---
    leaq ca_cmd_subtract(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_subtract

    # --- multiply ---
    leaq ca_cmd_multiply(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_multiply

    # --- divide ---
    leaq ca_cmd_divide(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_divide

    # --- compare_eq ---
    leaq ca_cmd_compare_eq(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_compare_eq

    # --- compare_lt ---
    leaq ca_cmd_compare_lt(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_compare_lt

    # --- compare_gt ---
    leaq ca_cmd_compare_gt(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_compare_gt

    # --- label ---
    leaq ca_cmd_label(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_noop

    # --- jump ---
    leaq ca_cmd_jump(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_jump

    # --- jump_if ---
    leaq ca_cmd_jump_if(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_jump_if

    # --- jump_if_not ---
    leaq ca_cmd_jump_if_not(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_jump_if_not

    # --- define ---
    leaq ca_cmd_define(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_define

    # --- invoke ---
    leaq ca_cmd_invoke(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_invoke

    # --- return ---
    leaq ca_cmd_return(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_return

    # --- string ---
    leaq ca_cmd_string(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_string

    # --- string_length ---
    leaq ca_cmd_string_len(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_string_length

    # --- push ---
    leaq ca_cmd_push(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_push

    # --- pop ---
    leaq ca_cmd_pop(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_pop

    # --- sys_exit ---
    leaq ca_cmd_sys_exit(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_exit

    # --- file_read ---
    leaq ca_cmd_file_read(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_file_read

    # --- map_new ---
    leaq ca_cmd_map_new(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_new

    # --- map_set ---
    leaq ca_cmd_map_set(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_set

    # --- map_get ---
    leaq ca_cmd_map_get(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_get

    # --- map_has ---
    leaq ca_cmd_map_has(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_has

    # --- map_set_dynamic ---
    leaq ca_cmd_map_setd(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_setd

    # --- map_get_dynamic ---
    leaq ca_cmd_map_getd(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_getd

    # --- array_new ---
    leaq ca_cmd_array_new(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_array_new

    # --- array_push ---
    leaq ca_cmd_array_push(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_array_push

    # --- array_get ---
    leaq ca_cmd_array_get(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_array_get

    # --- array_length ---
    leaq ca_cmd_array_len(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_array_len

    # --- array_set ---
    leaq ca_cmd_array_set(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_array_set

    # --- tree_parse ---
    leaq ca_cmd_tree_parse(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_parse

    # --- tree_type ---
    leaq ca_cmd_tree_type(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_type

    # --- tree_value ---
    leaq ca_cmd_tree_value(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_value

    # --- tree_advance ---
    leaq ca_cmd_tree_adv(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_advance

    # --- tree_save ---
    leaq ca_cmd_tree_save(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_save

    # --- tree_restore ---
    leaq ca_cmd_tree_rest(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_restore

    # --- tree_skip_block ---
    leaq ca_cmd_tree_skip(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_skip

    # --- tree_position ---
    leaq ca_cmd_tree_pos(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_pos

    # --- tree_seek ---
    leaq ca_cmd_tree_seek(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_seek

    # --- string_compare ---
    leaq ca_cmd_str_cmp(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_cmp

    # --- string_concat ---
    leaq ca_cmd_str_concat(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_concat

    # --- string_char_at ---
    leaq ca_cmd_str_charat(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_charat

    # --- string_starts_with ---
    leaq ca_cmd_str_starts(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_starts

    # --- string_append_char ---
    leaq ca_cmd_str_append(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_append

    # --- string_new ---
    leaq ca_cmd_str_new(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_new

    # --- string_finish ---
    leaq ca_cmd_str_finish(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_finish

    # --- string_append_buf ---
    leaq ca_cmd_str_appbuf(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_appbuf

    # --- typeof ---
    leaq ca_cmd_typeof(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_typeof

    # --- to_string ---
    leaq ca_cmd_to_string(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_to_string

    # --- to_number ---
    leaq ca_cmd_to_number(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_to_number

    # --- args_count ---
    leaq ca_cmd_args_count(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_args_count

    # --- args_get ---
    leaq ca_cmd_args_get(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_args_get

    # --- print_newline ---
    leaq ca_cmd_print_nl(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_print_nl

    # --- print_char ---
    leaq ca_cmd_print_char(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_print_char

    # Unknown command - print warning
    leaq ca_unknown_msg(%rip), %rdi
    call print_cstring
    movq %rbx, %rdi
    call print_cstring
    call print_newline
    popq %rbx
    ret

# === CA Command Implementations ===

# value <literal> - set current value
.ca_value:
    movq (%r13), %rax
    cmpq $4, %rax
    je .ca_val_word
    cmpq $5, %rax
    je .ca_val_str
    jmp .ca_val_done
.ca_val_word:
    movq 8(%r13), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .ca_val_as_str
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $16, %r13
    jmp .ca_val_done
.ca_val_as_str:
    movq 8(%r13), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $16, %r13
    jmp .ca_val_done
.ca_val_str:
    movq 8(%r13), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $16, %r13
.ca_val_done:
    popq %rbx
    ret

# log [args...] - print args or current value with newline
.ca_log:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_log_cur
    cmpq $0, %rax
    je .ca_log_cur
    cmpq $2, %rax
    je .ca_log_cur
.ca_log_args:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_log_nl
    cmpq $0, %rax
    je .ca_log_nl
    cmpq $2, %rax
    je .ca_log_nl
    cmpq $4, %rax
    je .ca_log_word
    cmpq $5, %rax
    je .ca_log_word
    addq $16, %r13
    jmp .ca_log_args
.ca_log_word:
    movq 8(%r13), %rdi
    call print_cstring
    addq $16, %r13
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_log_nl
    cmpq $0, %rax
    je .ca_log_nl
    cmpq $2, %rax
    je .ca_log_nl
    leaq ca_space(%rip), %rdi
    call print_cstring
    jmp .ca_log_args
.ca_log_nl:
    call print_newline
    popq %rbx
    ret
.ca_log_cur:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_log_int
    cmpq $3, %rax
    je .ca_log_str
    call print_newline
    popq %rbx
    ret
.ca_log_int:
    movq vm_cur_val(%rip), %rdi
    call print_number
    call print_newline
    popq %rbx
    ret
.ca_log_str:
    movq vm_cur_val(%rip), %rdi
    call print_cstring
    call print_newline
    popq %rbx
    ret

# print - print current value without newline
.ca_print:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_print_int
    cmpq $3, %rax
    je .ca_print_str
    popq %rbx
    ret
.ca_print_int:
    movq vm_cur_val(%rip), %rdi
    call print_number
    popq %rbx
    ret
.ca_print_str:
    movq vm_cur_val(%rip), %rdi
    call print_cstring
    popq %rbx
    ret

# register_set <id> <value> - FIXED: save register id properly
.ca_reg_set:
    movq 8(%r13), %rdi
    call vm_parse_int
    pushq %rax                     # save register id on stack
    addq $16, %r13
    movq (%r13), %rax
    cmpq $5, %rax
    je .ca_rs_str
    movq 8(%r13), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .ca_rs_word_str
    # Store integer
    movq %rax, %rdx               # value
    popq %rcx                     # restore register id
    leaq vm_regs(%rip), %rdi
    shlq $4, %rcx
    movq $2, (%rdi, %rcx)
    movq %rdx, 8(%rdi, %rcx)
    addq $16, %r13
    popq %rbx
    ret
.ca_rs_word_str:
    movq 8(%r13), %rax
    popq %rcx                     # restore register id
    leaq vm_regs(%rip), %rdi
    shlq $4, %rcx
    movq $3, (%rdi, %rcx)
    movq %rax, 8(%rdi, %rcx)
    addq $16, %r13
    popq %rbx
    ret
.ca_rs_str:
    movq 8(%r13), %rax
    popq %rcx                     # restore register id
    leaq vm_regs(%rip), %rdi
    shlq $4, %rcx
    movq $3, (%rdi, %rcx)
    movq %rax, 8(%rdi, %rcx)
    addq $16, %r13
    popq %rbx
    ret

# register_get <id>
.ca_reg_get:
    movq 8(%r13), %rdi
    call vm_parse_int
    leaq vm_regs(%rip), %rdi
    shlq $4, %rax
    movq (%rdi, %rax), %rcx
    movq 8(%rdi, %rax), %rdx
    movq %rcx, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
    addq $16, %r13
    popq %rbx
    ret

# register_to <id>
.ca_reg_to:
    movq 8(%r13), %rdi
    call vm_parse_int
    leaq vm_regs(%rip), %rdi
    shlq $4, %rax
    movq vm_cur_type(%rip), %rcx
    movq vm_cur_val(%rip), %rdx
    movq %rcx, (%rdi, %rax)
    movq %rdx, 8(%rdi, %rax)
    addq $16, %r13
    popq %rbx
    ret

# add <value> or add (pop from stack)
.ca_add:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_add_stack
    cmpq $2, %rax
    je .ca_add_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    addq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_add_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_add_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    addq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
.ca_add_nop:
    popq %rbx
    ret

# subtract <value> or subtract (pop from stack)
.ca_subtract:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_sub_stack
    cmpq $2, %rax
    je .ca_sub_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    subq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_sub_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_sub_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    subq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
.ca_sub_nop:
    popq %rbx
    ret

# multiply <value> or multiply (pop from stack)
.ca_multiply:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_mul_stack
    cmpq $2, %rax
    je .ca_mul_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    movq vm_cur_val(%rip), %rcx
    imulq %rax, %rcx
    movq %rcx, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_mul_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mul_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    movq vm_cur_val(%rip), %rcx
    imulq %rax, %rcx
    movq %rcx, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
.ca_mul_nop:
    popq %rbx
    ret

# divide <value> or divide (pop from stack)
.ca_divide:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_div_stack
    cmpq $2, %rax
    je .ca_div_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    movq %rax, %rcx
    movq vm_cur_val(%rip), %rax
    cqto
    idivq %rcx
    movq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_div_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_div_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rcx
    testq %rcx, %rcx
    jz .ca_div_nop
    movq vm_cur_val(%rip), %rax
    cqto
    idivq %rcx
    movq %rax, vm_cur_val(%rip)
    movq $2, vm_cur_type(%rip)
.ca_div_nop:
    popq %rbx
    ret

# compare_eq <value> or compare_eq (pop from stack)
.ca_compare_eq:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_ceq_stack
    cmpq $2, %rax
    je .ca_ceq_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    cmpq %rax, vm_cur_val(%rip)
    sete %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_ceq_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ceq_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    cmpq %rax, vm_cur_val(%rip)
    sete %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
.ca_ceq_nop:
    popq %rbx
    ret

# compare_lt <value> or compare_lt (pop from stack)
.ca_compare_lt:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_clt_stack
    cmpq $2, %rax
    je .ca_clt_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    movq vm_cur_val(%rip), %rcx
    cmpq %rax, %rcx
    setl %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_clt_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_clt_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    movq vm_cur_val(%rip), %rcx
    cmpq %rax, %rcx
    setl %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
.ca_clt_nop:
    popq %rbx
    ret

# compare_gt <value> or compare_gt (pop from stack)
.ca_compare_gt:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_cgt_stack
    cmpq $2, %rax
    je .ca_cgt_stack
    movq 8(%r13), %rdi
    call vm_parse_int
    movq vm_cur_val(%rip), %rcx
    cmpq %rax, %rcx
    setg %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    addq $16, %r13
    popq %rbx
    ret
.ca_cgt_stack:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_cgt_nop
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rax
    movq vm_cur_val(%rip), %rcx
    cmpq %rax, %rcx
    setg %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
.ca_cgt_nop:
    popq %rbx
    ret

# label <name> - no-op at runtime (collected in first pass)
.ca_noop:
    addq $16, %r13
    popq %rbx
    ret

# jump <label> - unconditional jump
.ca_jump:
    movq 8(%r13), %rdi
    call vm_find_label
    testq %rax, %rax
    jz .ca_jump_fail
    movq %rax, %r13
    movq $1, vm_jumped(%rip)
    popq %rbx
    ret
.ca_jump_fail:
    addq $16, %r13
    popq %rbx
    ret

# jump_if <label> - jump if comparison flag is true
.ca_jump_if:
    movq vm_comp_flag(%rip), %rax
    testq %rax, %rax
    jz .ca_ji_skip
    movq 8(%r13), %rdi
    call vm_find_label
    testq %rax, %rax
    jz .ca_ji_skip
    movq %rax, %r13
    movq $1, vm_jumped(%rip)
    popq %rbx
    ret
.ca_ji_skip:
    addq $16, %r13
    popq %rbx
    ret

# jump_if_not <label> - jump if comparison flag is false
.ca_jump_if_not:
    movq vm_comp_flag(%rip), %rax
    testq %rax, %rax
    jnz .ca_jin_skip
    movq 8(%r13), %rdi
    call vm_find_label
    testq %rax, %rax
    jz .ca_jin_skip
    movq %rax, %r13
    movq $1, vm_jumped(%rip)
    popq %rbx
    ret
.ca_jin_skip:
    addq $16, %r13
    popq %rbx
    ret

# define <name> [block] - skip block at runtime (collected in first pass)
.ca_define:
    # Skip name token
    addq $16, %r13
    # Skip block if present (find matching BLOCK_END)
    movq (%r13), %rax
    cmpq $1, %rax                 # BLOCK_START
    jne .ca_def_done
    addq $16, %r13
    movq $1, %rcx
.ca_def_skip:
    movq (%r13), %rax
    addq $16, %r13
    cmpq $1, %rax
    jne .ca_def_not_start
    incq %rcx
    jmp .ca_def_skip
.ca_def_not_start:
    cmpq $2, %rax
    jne .ca_def_skip
    decq %rcx
    jnz .ca_def_skip
.ca_def_done:
    popq %rbx
    ret

# invoke <name> - call a named procedure
.ca_invoke:
    movq 8(%r13), %rdi
    addq $16, %r13
    # Save return address on call stack
    movq vm_call_sp(%rip), %rcx
    leaq vm_call_stack(%rip), %rdx
    movq %r13, (%rdx, %rcx, 8)
    incq %rcx
    movq %rcx, vm_call_sp(%rip)
    # Find procedure body
    call vm_find_proc
    testq %rax, %rax
    jz .ca_inv_fail
    movq %rax, %r13
    movq $1, vm_jumped(%rip)
    popq %rbx
    ret
.ca_inv_fail:
    # Pop call stack since we pushed but failed
    movq vm_call_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_call_sp(%rip)
    popq %rbx
    ret

# return - return from procedure
.ca_return:
    movq vm_call_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ret_done
    decq %rcx
    movq %rcx, vm_call_sp(%rip)
    leaq vm_call_stack(%rip), %rdx
    movq (%rdx, %rcx, 8), %r13
    movq $1, vm_jumped(%rip)
.ca_ret_done:
    popq %rbx
    ret

# string <literal> - set current to string
.ca_string:
    movq 8(%r13), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $16, %r13
    popq %rbx
    ret

# string_length - get length of current string
.ca_string_length:
    movq vm_cur_val(%rip), %rdi
    call strlen
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# push - push current value onto stack
.ca_push:
    movq vm_val_sp(%rip), %rcx
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq vm_cur_type(%rip), %rax
    movq %rax, (%rdi, %rcx)
    movq vm_cur_val(%rip), %rax
    movq %rax, 8(%rdi, %rcx)
    shrq $4, %rcx
    incq %rcx
    movq %rcx, vm_val_sp(%rip)
    popq %rbx
    ret

# pop - pop from stack into current value
.ca_pop:
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_pop_empty
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq (%rdi, %rcx), %rax
    movq %rax, vm_cur_type(%rip)
    movq 8(%rdi, %rcx), %rax
    movq %rax, vm_cur_val(%rip)
.ca_pop_empty:
    popq %rbx
    ret

# sys_exit <code>
.ca_sys_exit:
    movq 8(%r13), %rdi
    call vm_parse_int
    movq %rax, %rdi
    call sys_exit

# file_read - read file path from current string, content becomes current
.ca_file_read:
    movq vm_cur_val(%rip), %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    call sys_open
    testq %rax, %rax
    js .ca_fr_fail
    pushq %rax
    movq $65536, %rdi
    call heap_alloc
    movq %rax, %rbx
    popq %rdi
    pushq %rdi
    movq %rbx, %rsi
    movq $65535, %rdx
    call sys_read
    movq %rax, %rcx
    movb $0, (%rbx, %rcx)
    popq %rdi
    pushq %rbx
    call sys_close
    popq %rbx
    movq $3, vm_cur_type(%rip)
    movq %rbx, vm_cur_val(%rip)
    popq %rbx
    ret
.ca_fr_fail:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    popq %rbx
    ret

# === Map Commands ===

# map_new - create empty map, set as current (type=6)
.ca_map_new:
    call vm_map_new
    movq $6, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# map_set <key> - pop value from stack, set key in current map
.ca_map_set:
    movq 8(%r13), %r8               # key string
    addq $16, %r13
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ms_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq (%rax, %rcx), %rdx        # type
    movq 8(%rax, %rcx), %rcx       # value
    movq vm_cur_val(%rip), %rdi     # map
    movq %r8, %rsi                  # key
    call vm_map_set
.ca_ms_done:
    popq %rbx
    ret

# map_get <key> - get value by key from current map
.ca_map_get:
    movq vm_cur_val(%rip), %rdi
    movq 8(%r13), %rsi
    addq $16, %r13
    call vm_map_get
    movq %rax, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
    popq %rbx
    ret

# map_has <key> - check if key exists, set compare flag
.ca_map_has:
    movq vm_cur_val(%rip), %rdi
    movq 8(%r13), %rsi
    addq $16, %r13
    call vm_map_has
    movq %rax, vm_comp_flag(%rip)
    popq %rbx
    ret

# map_set_dynamic - pop key (string), pop value, set in current map
.ca_map_setd:
    movq vm_cur_val(%rip), %r8      # map
    # Pop key
    movq vm_val_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %r9        # key string
    # Pop value
    movq vm_val_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq (%rax, %rcx), %rdx        # type
    movq 8(%rax, %rcx), %rcx       # value
    movq %r8, %rdi
    movq %r9, %rsi
    call vm_map_set
    popq %rbx
    ret

# map_get_dynamic - pop key, get from current map
.ca_map_getd:
    movq vm_cur_val(%rip), %rdi
    movq vm_val_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rsi       # key string
    call vm_map_get
    movq %rax, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
    popq %rbx
    ret

# === Array Commands ===

# array_new - create empty array, set as current (type=5)
.ca_array_new:
    call vm_array_new
    movq $5, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# array_push - pop value from stack, push to current array
.ca_array_push:
    movq vm_cur_val(%rip), %rdi     # array
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ap_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq (%rax, %rcx), %rsi        # type
    movq 8(%rax, %rcx), %rdx       # value
    call vm_array_push
.ca_ap_done:
    popq %rbx
    ret

# array_get - use current integer as index, pop array from stack
.ca_array_get:
    movq vm_cur_val(%rip), %rsi     # index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ag_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %r8
    shlq $4, %rcx
    movq 8(%r8, %rcx), %rdi        # array pointer
    call vm_array_get
    movq %rax, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
.ca_ag_done:
    popq %rbx
    ret

# array_length - get length of current array
.ca_array_len:
    movq vm_cur_val(%rip), %rdi
    call vm_array_length
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# array_set - pop index, pop value, set in current array
.ca_array_set:
    # TODO: implement array_set
    popq %rbx
    ret

# === Tree Navigation Commands ===

# tree_parse - parse current string as Crown, set up cursor
.ca_tree_parse:
    movq vm_cur_val(%rip), %rdi
    call strlen
    pushq %rax                      # save length
    pushq %rdi                      # save source ptr (may be clobbered)
    # Reload source pointer (strlen preserves %rdi on our impl)
    movq vm_cur_val(%rip), %r8
    # Allocate heap buffer for parse tree
    movq $262144, %rdi
    call heap_alloc_zero
    movq %rax, %r9                  # save buffer ptr
    popq %rdi                       # restore source ptr
    popq %rsi                       # restore length
    # parse_common(input=%rdi, length=%rsi, output=%rdx)
    movq vm_cur_val(%rip), %rdi     # source string
    movq %r9, %rdx                  # output buffer
    pushq %r9                       # save buffer base
    call parse_common
    popq %r9                        # restore buffer base
    # Set cursor to buffer + 16 (skip implicit BLOCK_START)
    addq $16, %r9
    movq %r9, tree_cursor(%rip)
    popq %rbx
    ret

# tree_type - get node type at cursor as integer
.ca_tree_type:
    movq tree_cursor(%rip), %rdi
    movq (%rdi), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# tree_value - get node value at cursor as string
.ca_tree_value:
    movq tree_cursor(%rip), %rdi
    movq 8(%rdi), %rax
    testq %rax, %rax
    jz .ca_tv_undef
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret
.ca_tv_undef:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    popq %rbx
    ret

# tree_advance - move cursor forward one node (16 bytes)
.ca_tree_advance:
    movq tree_cursor(%rip), %rax
    addq $16, %rax
    movq %rax, tree_cursor(%rip)
    popq %rbx
    ret

# tree_save - push cursor position to internal stack
.ca_tree_save:
    movq tree_cursor_sp(%rip), %rcx
    leaq tree_cursor_stack(%rip), %rdi
    movq tree_cursor(%rip), %rax
    movq %rax, (%rdi, %rcx, 8)
    incq %rcx
    movq %rcx, tree_cursor_sp(%rip)
    popq %rbx
    ret

# tree_restore - pop cursor position from internal stack
.ca_tree_restore:
    movq tree_cursor_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_tr_done
    decq %rcx
    movq %rcx, tree_cursor_sp(%rip)
    leaq tree_cursor_stack(%rip), %rdi
    movq (%rdi, %rcx, 8), %rax
    movq %rax, tree_cursor(%rip)
.ca_tr_done:
    popq %rbx
    ret

# tree_skip_block - skip to matching BLOCK_END
.ca_tree_skip:
    movq tree_cursor(%rip), %rdi
    movq $1, %rcx                   # nesting depth
.ca_tsb_loop:
    movq (%rdi), %rax
    addq $16, %rdi
    cmpq $1, %rax                   # BLOCK_START
    jne .ca_tsb_ns
    incq %rcx
    jmp .ca_tsb_loop
.ca_tsb_ns:
    cmpq $2, %rax                   # BLOCK_END
    jne .ca_tsb_loop
    decq %rcx
    jnz .ca_tsb_loop
    movq %rdi, tree_cursor(%rip)
    popq %rbx
    ret

# tree_position - get cursor as integer (for saving to register)
.ca_tree_pos:
    movq tree_cursor(%rip), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# tree_seek - set cursor from current integer value
.ca_tree_seek:
    movq vm_cur_val(%rip), %rax
    movq %rax, tree_cursor(%rip)
    popq %rbx
    ret

# === String Commands ===

# string_compare <arg> - compare current string with arg, set compare flag
.ca_str_cmp:
    movq 8(%r13), %rsi              # arg string
    addq $16, %r13
    movq vm_cur_val(%rip), %rdi
    call strcmp
    testq %rax, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    popq %rbx
    ret

# string_concat - pop string from stack, concat with current
.ca_str_concat:
    # Pop string from stack
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_sc_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %r8        # popped string
    # Get current string
    movq vm_cur_val(%rip), %r9
    # Calculate lengths
    movq %r8, %rdi
    call strlen
    movq %rax, %r10                 # len1
    movq %r9, %rdi
    call strlen
    movq %rax, %r11                 # len2
    # Allocate new buffer
    leaq 1(%r10, %r11), %rdi
    call heap_alloc
    # Copy first string (popped = goes first)
    movq %rax, %rdi                 # dest
    movq %r8, %rsi                  # src
    movq %r10, %rdx                 # len
    pushq %rax
    call memcpy
    popq %rax
    # Copy second string (current)
    leaq (%rax, %r10), %rdi
    movq %r9, %rsi
    movq %r11, %rdx
    pushq %rax
    call memcpy
    popq %rax
    # Null-terminate
    movq %r10, %rcx
    addq %r11, %rcx
    movb $0, (%rax, %rcx)
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_sc_done:
    popq %rbx
    ret

# string_char_at - get char at index (current int) from string on stack
.ca_str_charat:
    movq vm_cur_val(%rip), %rsi     # index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_sca_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # string pointer
    movzbq (%rdi, %rsi), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_sca_done:
    popq %rbx
    ret

# string_starts_with <prefix> - set compare flag
.ca_str_starts:
    movq 8(%r13), %rsi              # prefix string
    addq $16, %r13
    movq vm_cur_val(%rip), %rdi     # current string
    # Get prefix length
    pushq %rdi
    pushq %rsi
    movq %rsi, %rdi
    call strlen
    movq %rax, %rdx                 # prefix len
    popq %rsi
    popq %rdi
    call starts_with
    movq %rax, vm_comp_flag(%rip)
    popq %rbx
    ret

# string_append_char - append current int as char to build buffer
.ca_str_append:
    movq str_build_ptr(%rip), %rdi
    movq str_build_len(%rip), %rcx
    movq vm_cur_val(%rip), %rax
    movb %al, (%rdi, %rcx)
    incq %rcx
    movq %rcx, str_build_len(%rip)
    popq %rbx
    ret

# string_new - create empty string build buffer on heap
.ca_str_new:
    movq $4096, %rdi
    call heap_alloc_zero
    movq %rax, str_build_ptr(%rip)
    movq $0, str_build_len(%rip)
    popq %rbx
    ret

# string_append_buf - append current string to build buffer
.ca_str_appbuf:
    movq vm_cur_val(%rip), %rsi
    movq str_build_ptr(%rip), %rdi
    movq str_build_len(%rip), %rcx
.ca_sab_loop:
    movb (%rsi), %al
    testb %al, %al
    jz .ca_sab_done
    movb %al, (%rdi, %rcx)
    incq %rsi
    incq %rcx
    jmp .ca_sab_loop
.ca_sab_done:
    movq %rcx, str_build_len(%rip)
    popq %rbx
    ret

# string_finish - finalize build buffer as current string
.ca_str_finish:
    movq str_build_ptr(%rip), %rdi
    movq str_build_len(%rip), %rcx
    movb $0, (%rdi, %rcx)          # null-terminate
    movq $3, vm_cur_type(%rip)
    movq %rdi, vm_cur_val(%rip)
    popq %rbx
    ret

# === Type Commands ===

# typeof - get type name as string
.ca_typeof:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_ty_num
    cmpq $3, %rax
    je .ca_ty_str
    cmpq $4, %rax
    je .ca_ty_bool
    cmpq $5, %rax
    je .ca_ty_arr
    cmpq $6, %rax
    je .ca_ty_map
    cmpq $1, %rax
    je .ca_ty_null
    # Default: undefined
    leaq ca_type_undefined(%rip), %rax
    jmp .ca_ty_set
.ca_ty_num:
    leaq ca_type_number(%rip), %rax
    jmp .ca_ty_set
.ca_ty_str:
    leaq ca_type_string(%rip), %rax
    jmp .ca_ty_set
.ca_ty_bool:
    leaq ca_type_boolean(%rip), %rax
    jmp .ca_ty_set
.ca_ty_arr:
    leaq ca_type_array(%rip), %rax
    jmp .ca_ty_set
.ca_ty_map:
    leaq ca_type_map(%rip), %rax
    jmp .ca_ty_set
.ca_ty_null:
    leaq ca_type_null(%rip), %rax
.ca_ty_set:
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# to_string - convert current value to string representation
.ca_to_string:
    movq vm_cur_type(%rip), %rax
    cmpq $3, %rax
    je .ca_ts_done                  # already string
    cmpq $2, %rax
    je .ca_ts_int
    cmpq $4, %rax
    je .ca_ts_bool
    # Other: set to "undefined"
    leaq ca_type_undefined(%rip), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_ts_done:
    popq %rbx
    ret
.ca_ts_int:
    movq vm_cur_val(%rip), %rdi
    subq $32, %rsp
    movq %rsp, %rsi
    call itoa
    movq %rax, %rsi                 # length
    movq %rsp, %rdi                 # buffer
    call strdup_len
    addq $32, %rsp
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret
.ca_ts_bool:
    movq vm_cur_val(%rip), %rax
    testq %rax, %rax
    jz .ca_ts_false
    leaq ca_type_boolean(%rip), %rax  # "true" would be better
    jmp .ca_ts_bset
.ca_ts_false:
    leaq ca_type_boolean(%rip), %rax
.ca_ts_bset:
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# to_number - convert current to number
.ca_to_number:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_tn_done                  # already number
    cmpq $3, %rax
    je .ca_tn_str
    # Other: set to 0
    movq $2, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
.ca_tn_done:
    popq %rbx
    ret
.ca_tn_str:
    movq vm_cur_val(%rip), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .ca_tn_zero
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret
.ca_tn_zero:
    movq $2, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    popq %rbx
    ret

# === Args Commands ===

# args_count - set current to number of runtime args
.ca_args_count:
    movq rt_args_count(%rip), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# args_get - get arg at index (current integer)
.ca_args_get:
    movq vm_cur_val(%rip), %rax
    leaq rt_args(%rip), %rdi
    movq (%rdi, %rax, 8), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    popq %rbx
    ret

# === Additional I/O Commands ===

# print_newline
.ca_print_nl:
    call print_newline
    popq %rbx
    ret

# print_char - print current integer as ASCII character
.ca_print_char:
    movq vm_cur_val(%rip), %rax
    subq $1, %rsp
    movb %al, (%rsp)
    movq $1, %rax                   # sys_write
    movq $1, %rdi                   # stdout
    movq %rsp, %rsi                 # buffer
    movq $1, %rdx                   # length
    syscall
    addq $1, %rsp
    popq %rbx
    ret

# === VM Helper Functions ===

# vm_parse_int(str=%rdi) -> value in %rax, valid flag in %rdx (1=valid, 0=not)
vm_parse_int:
    pushq %rbx
    xorq %rax, %rax
    xorq %rdx, %rdx
    xorq %rcx, %rcx
    movq $1, %rbx
    movb (%rdi), %r8b
    cmpb $45, %r8b
    jne .vpi_loop
    movq $-1, %rbx
    incq %rdi
.vpi_loop:
    movb (%rdi, %rcx), %r8b
    testb %r8b, %r8b
    jz .vpi_done
    cmpb $48, %r8b
    jl .vpi_nan
    cmpb $57, %r8b
    jg .vpi_nan
    imulq $10, %rax
    movzbq %r8b, %r9
    subq $48, %r9
    addq %r9, %rax
    incq %rcx
    jmp .vpi_loop
.vpi_done:
    testq %rcx, %rcx
    jz .vpi_nan
    imulq %rbx, %rax
    movq $1, %rdx
    popq %rbx
    ret
.vpi_nan:
    xorq %rax, %rax
    xorq %rdx, %rdx
    popq %rbx
    ret

# vm_collect_labels - first pass: find label and define statements
# Scans through entire tree including inside define blocks (tracking depth)
vm_collect_labels:
    pushq %rbx
    pushq %r14
    pushq %r15
    movq %r12, %r14
    xorq %r15, %r15            # r15 = nesting depth (0 = top level)
.vcl_loop:
    movq (%r14), %rax
    testq %rax, %rax           # END (type 0)?
    jz .vcl_done
    cmpq $1, %rax              # BLOCK_START?
    je .vcl_block_start
    cmpq $2, %rax              # BLOCK_END?
    je .vcl_block_end
    cmpq $4, %rax              # WORD?
    jne .vcl_next
    # Check if it is "label"
    movq 8(%r14), %rdi
    leaq ca_cmd_label(%rip), %rsi
    call strcmp
    testq %rax, %rax
    jnz .vcl_check_define
    # Found "label" - next token is the name
    addq $16, %r14
    movq 8(%r14), %rdi
    # Skip to STMT_END
    addq $16, %r14
.vcl_label_skip:
    movq (%r14), %rax
    cmpq $3, %rax
    je .vcl_label_found
    addq $16, %r14
    jmp .vcl_label_skip
.vcl_label_found:
    addq $16, %r14             # past STMT_END = label target
    # Store label: name + target pointer
    movq vm_label_count(%rip), %rcx
    leaq vm_labels(%rip), %rsi
    shlq $4, %rcx
    movq %rdi, (%rsi, %rcx)
    movq %r14, 8(%rsi, %rcx)
    shrq $4, %rcx
    incq %rcx
    movq %rcx, vm_label_count(%rip)
    jmp .vcl_loop

.vcl_check_define:
    movq 8(%r14), %rdi
    leaq ca_cmd_define(%rip), %rsi
    call strcmp
    testq %rax, %rax
    jnz .vcl_next
    # Found "define" - next token is name, then BLOCK_START
    addq $16, %r14
    movq 8(%r14), %rdi         # procedure name
    addq $16, %r14             # past name token
    movq %r14, %rbx            # body start (should be BLOCK_START)
    # Store proc: name + body pointer
    movq vm_proc_count(%rip), %rcx
    leaq vm_procs(%rip), %rsi
    shlq $4, %rcx
    movq %rdi, (%rsi, %rcx)
    movq %rbx, 8(%rsi, %rcx)
    shrq $4, %rcx
    incq %rcx
    movq %rcx, vm_proc_count(%rip)
    # Continue scanning through the block for labels (do not skip)
    # The BLOCK_START will be handled by .vcl_block_start
    jmp .vcl_loop

.vcl_block_start:
    incq %r15
    addq $16, %r14
    jmp .vcl_loop

.vcl_block_end:
    decq %r15
    testq %r15, %r15
    js .vcl_done               # depth < 0 = exited top-level block
    addq $16, %r14
    jmp .vcl_loop

.vcl_next:
    addq $16, %r14
    jmp .vcl_loop
.vcl_done:
    popq %r15
    popq %r14
    popq %rbx
    ret

# vm_find_label(name=%rdi) -> target pointer in %rax (0 if not found)
vm_find_label:
    pushq %rbx
    movq vm_label_count(%rip), %rcx
    leaq vm_labels(%rip), %rbx
    xorq %rdx, %rdx
.vfl_loop:
    cmpq %rcx, %rdx
    jge .vfl_notfound
    movq %rdx, %rax
    shlq $4, %rax
    pushq %rdi
    pushq %rcx
    pushq %rdx
    movq (%rbx, %rax), %rsi
    call strcmp
    popq %rdx
    popq %rcx
    popq %rdi
    testq %rax, %rax
    jz .vfl_found
    incq %rdx
    jmp .vfl_loop
.vfl_found:
    movq %rdx, %rax
    shlq $4, %rax
    movq 8(%rbx, %rax), %rax
    popq %rbx
    ret
.vfl_notfound:
    xorq %rax, %rax
    popq %rbx
    ret

# vm_find_proc(name=%rdi) -> body pointer in %rax (0 if not found)
# Returns pointer past BLOCK_START (first node inside block)
vm_find_proc:
    pushq %rbx
    movq vm_proc_count(%rip), %rcx
    leaq vm_procs(%rip), %rbx
    xorq %rdx, %rdx
.vfp_loop:
    cmpq %rcx, %rdx
    jge .vfp_notfound
    movq %rdx, %rax
    shlq $4, %rax
    pushq %rdi
    pushq %rcx
    pushq %rdx
    movq (%rbx, %rax), %rsi
    call strcmp
    popq %rdx
    popq %rcx
    popq %rdi
    testq %rax, %rax
    jz .vfp_found
    incq %rdx
    jmp .vfp_loop
.vfp_found:
    movq %rdx, %rax
    shlq $4, %rax
    movq 8(%rbx, %rax), %rax
    # Skip past BLOCK_START
    cmpq $1, (%rax)
    jne .vfp_ret
    addq $16, %rax
.vfp_ret:
    popq %rbx
    ret
.vfp_notfound:
    xorq %rax, %rax
    popq %rbx
    ret

.globl _start
_start:
    # Save initial stack pointer (argc/argv access)
    movq %rsp, saved_rsp(%rip)

    # Initialize heap
    call heap_init

    # Parse command line arguments
    call parse_args

    # Print banner to stderr unless suppressed by -0/--zero
    movq banner_suppress(%rip), %rax
    testq %rax, %rax
    jnz .skip_banner
    movq $1, %rax
    movq $2, %rdi
    leaq banner(%rip), %rsi
    movq $banner_len, %rdx
    syscall
.skip_banner:

    # Check if any .ca files were given
    movq ca_file_count(%rip), %rax
    testq %rax, %rax
    jz .no_files

    # Run each .ca file
    call run_ca_files
    jmp .exit_success

.no_files:
    # Default: run engines/a.ca with repl.cr as runtime arg
    leaq default_engine(%rip), %rax
    leaq ca_files(%rip), %rdi
    movq %rax, (%rdi)
    movq $1, ca_file_count(%rip)
    leaq default_repl(%rip), %rax
    leaq rt_args(%rip), %rdi
    movq %rax, (%rdi)
    movq $1, rt_args_count(%rip)
    call run_ca_files
    jmp .exit_success

.exit_success:
    xorq %rdi, %rdi
    call sys_exit

# parse_args - split argv on "--"
# Before "--": .ca file paths -> ca_files[]
# After "--":  runtime args   -> rt_args[]
parse_args:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    movq saved_rsp(%rip), %rbx
    movq (%rbx), %r12              # r12 = argc
    leaq 8(%rbx), %r13             # r13 = &argv[0]
    # Skip argv[0] (program name)
    addq $8, %r13
    decq %r12
    xorq %r14, %r14                # 0 = before --, 1 = after --
.pa_loop:
    testq %r12, %r12
    jz .pa_done
    movq (%r13), %rdi              # current arg string

    # Check for -0 (only before --)
    testq %r14, %r14
    jnz .pa_check_dashdash
    leaq opt_zero_short(%rip), %rsi
    pushq %rdi
    call strcmp
    popq %rdi
    testq %rax, %rax
    jz .pa_set_zero

    # Check for --zero (only before --)
    leaq opt_zero_long(%rip), %rsi
    pushq %rdi
    call strcmp
    popq %rdi
    testq %rax, %rax
    jz .pa_set_zero

.pa_check_dashdash:
    # Check for "--" separator
    leaq dashdash(%rip), %rsi
    pushq %rdi
    call strcmp
    popq %rdi
    testq %rax, %rax
    jz .pa_separator

    testq %r14, %r14
    jnz .pa_rt_arg

    # Before --: add to ca_files
    movq ca_file_count(%rip), %rcx
    leaq ca_files(%rip), %rsi
    movq %rdi, (%rsi, %rcx, 8)
    incq %rcx
    movq %rcx, ca_file_count(%rip)
    jmp .pa_next

.pa_set_zero:
    movq $1, banner_suppress(%rip)
    jmp .pa_next

.pa_separator:
    movq $1, %r14
    jmp .pa_next

.pa_rt_arg:
    # After --: add to rt_args
    movq rt_args_count(%rip), %rcx
    leaq rt_args(%rip), %rsi
    movq %rdi, (%rsi, %rcx, 8)
    incq %rcx
    movq %rcx, rt_args_count(%rip)

.pa_next:
    addq $8, %r13
    decq %r12
    jmp .pa_loop
.pa_done:
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# load_file(path=%rdi) -> 0 on success, -1 on failure in %rax
# Reads file into file_buffer, sets file_size
load_file:
    pushq %rbx
    # Open file (O_RDONLY = 0)
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    call sys_open
    testq %rax, %rax
    js .lf_fail
    movq %rax, %rbx               # save fd
    # Read file
    movq %rbx, %rdi
    leaq file_buffer(%rip), %rsi
    movq $65535, %rdx
    call sys_read
    testq %rax, %rax
    js .lf_fail_close
    movq %rax, file_size(%rip)
    # Null-terminate the buffer
    leaq file_buffer(%rip), %rdi
    movb $0, (%rdi, %rax)
    # Close file
    movq %rbx, %rdi
    call sys_close
    xorq %rax, %rax
    popq %rbx
    ret
.lf_fail_close:
    movq %rbx, %rdi
    call sys_close
.lf_fail:
    movq $-1, %rax
    popq %rbx
    ret

# run_ca_files - load, parse, and run each .ca file sequentially
# Each file gets a fresh VM init (independent execution)
run_ca_files:
    pushq %rbx
    pushq %r12
    xorq %rbx, %rbx               # file index
.rca_loop:
    cmpq ca_file_count(%rip), %rbx
    jge .rca_done
    # Load the .ca file
    leaq ca_files(%rip), %rdi
    movq (%rdi, %rbx, 8), %rdi
    call load_file
    testq %rax, %rax
    js .rca_fail
    # Parse as CrownAssembly
    leaq file_buffer(%rip), %rdi
    movq file_size(%rip), %rsi
    call parse_ca
    # Initialize and run VM
    call vm_init
    call vm_run
    incq %rbx
    jmp .rca_loop
.rca_fail:
    leaq err_open_fail(%rip), %rdi
    call print_cstring
    incq %rbx
    jmp .rca_loop
.rca_done:
    popq %r12
    popq %rbx
    ret
