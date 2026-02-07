# CrownAssembly VM Interpreter
# Walks the parse tree and dispatches CA commands
#
# VM value types (stored as type tag + 8-byte data):
#   0 = undefined, 1 = null, 2 = integer, 3 = string (ptr)
#   4 = boolean (0/1), 5 = array (ptr), 6 = map (ptr)
#
# Register bank: 256 slots, each 16 bytes (type + value)
# Current value: type + value (the implicit accumulator)

get emit_bss, call '    .lcomm vm_regs, 4096
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
    .lcomm vm_run_stack, 512
    .lcomm vm_run_sp, 8
    .lcomm module_parse_buf, 262144
    .lcomm reusable_tree_buf, 8
    .lcomm reusable_file_buf, 8'

get emit_data, call '# CA command name strings for dispatch
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
ca_cmd_compare_str_eq: .asciz "compare_string_eq"
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
ca_cmd_file_release:.asciz "file_release"
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
ca_cmd_tree_release: .asciz "tree_release"
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
ca_cmd_run_ca_string: .asciz "run_ca_string"
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
ca_cmd_heap_alloc:   .asciz "heap_alloc"
ca_cmd_poke8:        .asciz "poke8"
ca_cmd_peek8:        .asciz "peek8"
ca_cmd_map_hasd:     .asciz "map_has_dynamic"
ca_cmd_map_len:      .asciz "map_length_entries"
ca_cmd_map_key_at:   .asciz "map_key_at"
ca_cmd_map_type_at:  .asciz "map_type_at"
ca_cmd_map_val_at:   .asciz "map_val_at"
ca_cmd_map_delete:   .asciz "map_delete"
ca_cmd_map_copy:     .asciz "map_copy"
ca_cmd_sys_getcwd:   .asciz "sys_getcwd"
ca_cmd_sys_getdents: .asciz "sys_getdents"
ca_cmd_sys_stat_f:   .asciz "sys_stat_file"
ca_cmd_sys_epoch:    .asciz "sys_epoch"
    ca_cmd_sys_date_str: .asciz "sys_date_string"
    ca_cmd_sys_local_min: .asciz "sys_local_minutes"
ca_cmd_str_indexof:  .asciz "string_index_of"
ca_cmd_str_endswith: .asciz "string_ends_with"
ca_cmd_str_slice:    .asciz "string_slice"
ca_cmd_str_concat2:  .asciz "str_concat"
ca_cmd_str_dup:      .asciz "str_dup"
ca_true_str:         .asciz "true"
ca_false_str:        .asciz "false"
ca_unknown_msg:      .asciz "Unknown CA command: "
ca_space:            .asciz " "'

get emit_text, call '# === CrownAssembly VM ===

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
    # Guard: avoid dereferencing null or invalid tree cursor
    testq %r13, %r13
    jz .vm_really_done
    leaq parse_tree(%rip), %r8
    cmpq %r8, %r13
    jb .vm_really_done
    movq (%r13), %rax              # node type
    testq %rax, %rax
    jz .vm_check_run_stack         # END marker

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
    jz .vm_check_run_stack         # top-level BLOCK_END = done
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
    testq %r13, %r13
    jz .vm_really_done
    leaq parse_tree(%rip), %r8
    cmpq %r8, %r13
    jb .vm_really_done
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
    testq %r13, %r13
    jz .vm_really_done
    leaq parse_tree(%rip), %r8
    cmpq %r8, %r13
    jb .vm_really_done
    movq (%r13), %rax
    cmpq $3, %rax                  # STMT_END
    je .vm_past_stmt
    cmpq $0, %rax                  # END
    je .vm_check_run_stack
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

.vm_check_run_stack:
    movq vm_run_sp(%rip), %rax
    testq %rax, %rax
    jz .vm_really_done
    decq %rax
    movq %rax, vm_run_sp(%rip)
    leaq vm_run_stack(%rip), %rdx
    movq (%rdx, %rax, 8), %r13
    jmp .vm_loop

.vm_really_done:
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# Safe return from command handlers. Restore rbx and return to vm_loop.
# (A previous guard that exited when 8(%rsp)==0 caused false early exit after log.)
.vm_safe_ret:
    popq %rbx
    ret
.vm_ret_corrupt:
    addq $8, %rsp
    popq %rbx
    jmp .vm_really_done

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

    # --- compare_string_eq ---
    leaq ca_cmd_compare_str_eq(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_compare_string_eq

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

    # --- file_release ---
    leaq ca_cmd_file_release(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_file_release

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

    # --- tree_release ---
    leaq ca_cmd_tree_release(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_tree_release

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

    # --- run_ca_string ---
    leaq ca_cmd_run_ca_string(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_run_ca_string

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

    # --- heap_alloc ---
    leaq ca_cmd_heap_alloc(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_heap_alloc

    # --- poke8 ---
    leaq ca_cmd_poke8(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_poke8

    # --- peek8 ---
    leaq ca_cmd_peek8(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_peek8

    # --- map_has_dynamic ---
    leaq ca_cmd_map_hasd(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_hasd

    # --- map_length_entries ---
    leaq ca_cmd_map_len(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_len

    # --- map_key_at ---
    leaq ca_cmd_map_key_at(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_key_at

    # --- map_type_at ---
    leaq ca_cmd_map_type_at(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_type_at

    # --- map_val_at ---
    leaq ca_cmd_map_val_at(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_val_at

    # --- map_delete ---
    leaq ca_cmd_map_delete(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_del

    # --- map_copy ---
    leaq ca_cmd_map_copy(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_map_cpy

    # --- sys_getcwd ---
    leaq ca_cmd_sys_getcwd(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_getcwd

    # --- sys_getdents ---
    leaq ca_cmd_sys_getdents(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_getdents

    # --- sys_stat_file ---
    leaq ca_cmd_sys_stat_f(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_stat_f

    # --- sys_epoch ---
    leaq ca_cmd_sys_epoch(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_epoch

    # --- sys_date_string ---
    leaq ca_cmd_sys_date_str(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_date_string

    # --- sys_local_minutes ---
    leaq ca_cmd_sys_local_min(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_sys_local_minutes

    # --- string_index_of ---
    leaq ca_cmd_str_indexof(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_indexof

    # --- string_ends_with ---
    leaq ca_cmd_str_endswith(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_endswith

    # --- string_slice ---
    leaq ca_cmd_str_slice(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_slice

    # --- str_concat ---
    leaq ca_cmd_str_concat2(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_concat2

    # --- str_dup ---
    leaq ca_cmd_str_dup(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .ca_str_dup

    # Unknown command - print warning
    leaq ca_unknown_msg(%rip), %rdi
    call print_cstring
    movq %rbx, %rdi
    call print_cstring
    call print_newline
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_log_cur:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_log_int
    cmpq $3, %rax
    je .ca_log_str
    call print_newline
    jmp .vm_safe_ret
.ca_log_int:
    movq vm_cur_val(%rip), %rdi
    call print_number
    call print_newline
    jmp .vm_safe_ret
.ca_log_str:
    movq vm_cur_val(%rip), %rdi
    call print_cstring
    call print_newline
    jmp .vm_safe_ret

# print - print current value without newline
.ca_print:
    movq vm_cur_type(%rip), %rax
    cmpq $2, %rax
    je .ca_print_int
    cmpq $3, %rax
    je .ca_print_str
    jmp .vm_safe_ret
.ca_print_int:
    movq vm_cur_val(%rip), %rdi
    call print_number
    jmp .vm_safe_ret
.ca_print_str:
    movq vm_cur_val(%rip), %rdi
    call print_cstring
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_rs_word_str:
    movq 8(%r13), %rax
    popq %rcx                     # restore register id
    leaq vm_regs(%rip), %rdi
    shlq $4, %rcx
    movq $3, (%rdi, %rcx)
    movq %rax, 8(%rdi, %rcx)
    addq $16, %r13
    jmp .vm_safe_ret
.ca_rs_str:
    movq 8(%r13), %rax
    popq %rcx                     # restore register id
    leaq vm_regs(%rip), %rdi
    shlq $4, %rcx
    movq $3, (%rdi, %rcx)
    movq %rax, 8(%rdi, %rcx)
    addq $16, %r13
    jmp .vm_safe_ret

# register_get <id>
.ca_reg_get:
    movq 8(%r13), %rdi
    testq %rdi, %rdi
    jz .ca_reg_get_zero
    call vm_parse_int
    jmp .ca_reg_get_check
.ca_reg_get_zero:
    xorq %rax, %rax
.ca_reg_get_check:
    # Bounds check: vm_regs has 256 slots; clamp invalid index to 0 so we still produce output
    cmpq $256, %rax
    jb .ca_reg_get_ok
    xorq %rax, %rax
.ca_reg_get_ok:
    leaq vm_regs(%rip), %rdi
    shlq $4, %rax
    movq (%rdi, %rax), %rcx
    movq 8(%rdi, %rax), %rdx
    movq %rcx, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
.ca_reg_get_done:
    addq $16, %r13
    jmp .vm_safe_ret
.ca_reg_get_undef:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .ca_reg_get_done

# register_to <id>
.ca_reg_to:
    movq 8(%r13), %rdi
    testq %rdi, %rdi
    jz .ca_reg_to_zero
    call vm_parse_int
    jmp .ca_reg_to_check
.ca_reg_to_zero:
    xorq %rax, %rax
.ca_reg_to_check:
    # Bounds check: clamp invalid index to 0 so we still store
    cmpq $256, %rax
    jb .ca_reg_to_ok
    xorq %rax, %rax
.ca_reg_to_ok:
    leaq vm_regs(%rip), %rdi
    shlq $4, %rax
    movq vm_cur_type(%rip), %rcx
    movq vm_cur_val(%rip), %rdx
    movq %rcx, (%rdi, %rax)
    movq %rdx, 8(%rdi, %rax)
.ca_reg_to_done:
    addq $16, %r13
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

# compare_eq <value> or compare_eq (pop from stack)
.ca_compare_eq:
    movq (%r13), %rax
    cmpq $3, %rax
    je .ca_ceq_stack
    cmpq $2, %rax
    je .ca_ceq_stack
    movq 8(%r13), %rdi
    testq %rdi, %rdi
    jz .ca_ceq_stack
    call vm_parse_int
    testq %rdx, %rdx
    jz .ca_ceq_stack
    cmpq %rax, vm_cur_val(%rip)
    sete %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    addq $16, %r13
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

# compare_string_eq <string> - compare current value (string) with string literal, set comp flag
.ca_compare_string_eq:
    movq (%r13), %rax
    cmpq $5, %rax                  # TOKEN_STRING
    jne .ca_cseq_nomatch
    movq vm_cur_type(%rip), %rcx
    cmpq $3, %rcx                  # current must be string (type 3)
    jne .ca_cseq_nomatch
    movq vm_cur_val(%rip), %rdi
    movq 8(%r13), %rsi
    testq %rdi, %rdi
    jz .ca_cseq_nomatch
    testq %rsi, %rsi
    jz .ca_cseq_nomatch
    pushq %rbx
    call strcmp
    popq %rbx
    testq %rax, %rax
    jz .ca_cseq_match
.ca_cseq_nomatch:
    movq $0, vm_comp_flag(%rip)
    addq $16, %r13
    jmp .vm_safe_ret
.ca_cseq_match:
    movq $1, vm_comp_flag(%rip)
    addq $16, %r13
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret

# label <name> - no-op at runtime (collected in first pass)
.ca_noop:
    addq $16, %r13
    jmp .vm_safe_ret

# jump <label> - unconditional jump
.ca_jump:
    movq 8(%r13), %rdi
    call vm_find_label
    testq %rax, %rax
    jz .ca_jump_fail
    movq %rax, %r13
    movq $1, vm_jumped(%rip)
    jmp .vm_safe_ret
.ca_jump_fail:
    addq $16, %r13
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_ji_skip:
    addq $16, %r13
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_jin_skip:
    addq $16, %r13
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_inv_fail:
    # Pop call stack since we pushed but failed
    movq vm_call_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_call_sp(%rip)
    jmp .vm_safe_ret

# return - return from procedure
.ca_return:
    movq vm_call_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ret_done
    decq %rcx
    movq %rcx, vm_call_sp(%rip)
    leaq vm_call_stack(%rip), %rdx
    movq (%rdx, %rcx, 8), %r13
    # Guard: if saved address is null/invalid, set r13=0 so vm_loop guard exits
    testq %r13, %r13
    jz .ca_ret_invalid
    leaq parse_tree(%rip), %r8
    cmpq %r8, %r13
    jb .ca_ret_invalid
    movq $1, vm_jumped(%rip)
    jmp .ca_ret_done
.ca_ret_invalid:
    xorq %r13, %r13
    movq $1, vm_jumped(%rip)
    jmp .vm_really_done
.ca_ret_done:
    jmp .vm_safe_ret

# string <literal> - set current to string
.ca_string:
    movq 8(%r13), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $16, %r13
    jmp .vm_safe_ret

# string_length - get length of current string
.ca_string_length:
    movq vm_cur_val(%rip), %rdi
    call strlen
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# sys_exit <code>
.ca_sys_exit:
    movq 8(%r13), %rdi
    call vm_parse_int
    movq %rax, %rdi
    call sys_exit

# file_read - read file path from current string, content becomes current
# Reuses reusable_file_buf when set (from file_release) to avoid OOM when loading many files
.ca_file_read:
    movq vm_cur_val(%rip), %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    call sys_open
    testq %rax, %rax
    js .ca_fr_fail
    movq %rax, %r8                 # r8 = fd
    movq reusable_file_buf(%rip), %rbx
    testq %rbx, %rbx
    jnz .ca_fr_use_reusable
    pushq %r8
    movq $262144, %rdi
    call heap_alloc
    movq %rax, %rbx                # rbx = buffer
    popq %r8
    jmp .ca_fr_after_alloc
.ca_fr_use_reusable:
    xorq %rax, %rax
    movq %rax, reusable_file_buf(%rip)
.ca_fr_after_alloc:
    xorq %r9, %r9                  # r9 = total bytes read
.ca_fr_read_loop:
    movq %r8, %rdi
    leaq (%rbx, %r9), %rsi
    movq $262143, %rdx
    subq %r9, %rdx
    testq %rdx, %rdx
    jle .ca_fr_read_done
    pushq %r8
    pushq %r9
    call sys_read
    popq %r9
    popq %r8
    testq %rax, %rax
    jle .ca_fr_read_done
    addq %rax, %r9
    jmp .ca_fr_read_loop
.ca_fr_read_done:
    movb $0, (%rbx, %r9)
    movq %r8, %rdi
    pushq %rbx
    call sys_close
    popq %rbx
    movq $3, vm_cur_type(%rip)
    movq %rbx, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_fr_fail:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .vm_safe_ret

# file_release - mark current value (file content buffer ptr) as reusable for next file_read
.ca_file_release:
    movq vm_cur_val(%rip), %rax
    movq %rax, reusable_file_buf(%rip)
    jmp .vm_safe_ret

# === Map Commands ===

# map_new - create empty map, set as current (type=6)
.ca_map_new:
    call vm_map_new
    movq $6, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# map_get <key> - get value by key from current map
.ca_map_get:
    movq vm_cur_val(%rip), %rdi
    movq 8(%r13), %rsi
    addq $16, %r13
    call vm_map_get
    movq %rax, vm_cur_type(%rip)
    movq %rdx, vm_cur_val(%rip)
    jmp .vm_safe_ret

# map_has <key> - check if key exists, set compare flag
.ca_map_has:
    movq vm_cur_val(%rip), %rdi
    movq 8(%r13), %rsi
    addq $16, %r13
    call vm_map_has
    movq %rax, vm_comp_flag(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# === Array Commands ===

# array_new - create empty array, set as current (type=5)
.ca_array_new:
    call vm_array_new
    movq $5, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# array_length - get length of current array
.ca_array_len:
    movq vm_cur_val(%rip), %rdi
    call vm_array_length
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# array_set - pop value, pop index, set in current array
.ca_array_set:
    movq vm_cur_val(%rip), %rdi     # array
    # Pop index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_aset_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rsi       # index
    # Pop value
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_aset_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq (%rax, %rcx), %rdx        # type
    movq 8(%rax, %rcx), %rcx       # value
    call vm_array_set
.ca_aset_done:
    jmp .vm_safe_ret

# === Tree Navigation Commands ===

# tree_parse - parse current string as Crown, set up cursor
# Reuses reusable_tree_buf when set (from tree_release) to avoid OOM when loading many files
.ca_tree_parse:
    movq vm_cur_val(%rip), %rdi
    call strlen
    pushq %rax                      # save length
    pushq %rdi                      # save source ptr (may be clobbered)
    movq vm_cur_val(%rip), %r8
    # Use reusable buffer if set, else allocate
    movq reusable_tree_buf(%rip), %r9
    testq %r9, %r9
    jnz .ca_tp_use_reusable
    movq $262144, %rdi
    call heap_alloc_zero
    movq %rax, %r9
    jmp .ca_tp_after_alloc
.ca_tp_use_reusable:
    xorq %rax, %rax
    movq %rax, reusable_tree_buf(%rip)
.ca_tp_after_alloc:
    popq %rdi
    popq %rsi
    movq vm_cur_val(%rip), %rdi
    movq %r9, %rdx
    pushq %r9
    call parse_common
    popq %r9
    addq $16, %r9
    movq %r9, tree_cursor(%rip)
    jmp .vm_safe_ret

# tree_release - mark current value (buffer ptr) as reusable for next tree_parse (avoids OOM)
.ca_tree_release:
    movq vm_cur_val(%rip), %rax
    movq %rax, reusable_tree_buf(%rip)
    jmp .vm_safe_ret

# tree_type - get node type at cursor as integer
.ca_tree_type:
    movq tree_cursor(%rip), %rdi
    testq %rdi, %rdi
    jz .ca_tt_bad
    cmpq $0x10000, %rdi
    jb .ca_tt_bad
    movq (%rdi), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_tt_bad:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .vm_safe_ret

# tree_value - get node value at cursor as string
.ca_tree_value:
    movq tree_cursor(%rip), %rdi
    testq %rdi, %rdi
    jz .ca_tv_undef
    cmpq $0x10000, %rdi
    jb .ca_tv_undef
    movq 8(%rdi), %rax
    testq %rax, %rax
    jz .ca_tv_undef
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_tv_undef:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .vm_safe_ret

# tree_advance - move cursor forward one node (16 bytes)
.ca_tree_advance:
    movq tree_cursor(%rip), %rax
    addq $16, %rax
    movq %rax, tree_cursor(%rip)
    jmp .vm_safe_ret

# tree_save - push cursor position to internal stack (max 1024 to avoid overflow)
.ca_tree_save:
    movq tree_cursor_sp(%rip), %rcx
    cmpq $1024, %rcx
    jge .vm_safe_ret
    leaq tree_cursor_stack(%rip), %rdi
    movq tree_cursor(%rip), %rax
    movq %rax, (%rdi, %rcx, 8)
    incq %rcx
    movq %rcx, tree_cursor_sp(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# tree_skip_block - skip to matching BLOCK_END (cursor should be AT BLOCK_START)
.ca_tree_skip:
    movq tree_cursor(%rip), %rdi
    testq %rdi, %rdi
    jz .vm_safe_ret
    cmpq $0x10000, %rdi
    jb .vm_safe_ret
    addq $16, %rdi                  # advance past initial BLOCK_START
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
    jmp .vm_safe_ret

# tree_position - get cursor as integer (for saving to register)
.ca_tree_pos:
    movq tree_cursor(%rip), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# tree_seek - set cursor from current integer value
.ca_tree_seek:
    movq vm_cur_val(%rip), %rax
    movq %rax, tree_cursor(%rip)
    jmp .vm_safe_ret

# === String Commands ===

# string_compare <arg> - compare current string with arg, set compare flag
.ca_str_cmp:
    movq 8(%r13), %rsi              # arg string
    addq $16, %r13
    testq %rsi, %rsi
    jz .ca_sc_null
    movq vm_cur_val(%rip), %rdi
    testq %rdi, %rdi
    jz .ca_sc_null
    call strcmp
    testq %rax, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, vm_comp_flag(%rip)
    jmp .vm_safe_ret
.ca_sc_null:
    movq $0, vm_comp_flag(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# string_append_char - append current int as char to build buffer
.ca_str_append:
    movq str_build_ptr(%rip), %rdi
    movq str_build_len(%rip), %rcx
    movq vm_cur_val(%rip), %rax
    movb %al, (%rdi, %rcx)
    incq %rcx
    movq %rcx, str_build_len(%rip)
    jmp .vm_safe_ret

# string_new - create empty string build buffer on heap
.ca_str_new:
    movq $4096, %rdi
    call heap_alloc_zero
    movq %rax, str_build_ptr(%rip)
    movq $0, str_build_len(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# string_finish - finalize build buffer as current string
.ca_str_finish:
    movq str_build_ptr(%rip), %rdi
    movq str_build_len(%rip), %rcx
    movb $0, (%rdi, %rcx)          # null-terminate
    movq $3, vm_cur_type(%rip)
    movq %rdi, vm_cur_val(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
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
    jmp .vm_safe_ret
.ca_ts_bool:
    movq vm_cur_val(%rip), %rax
    testq %rax, %rax
    jz .ca_ts_false
    leaq ca_true_str(%rip), %rax
    jmp .ca_ts_bset
.ca_ts_false:
    leaq ca_false_str(%rip), %rax
.ca_ts_bset:
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.ca_tn_str:
    movq vm_cur_val(%rip), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .ca_tn_zero
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_tn_zero:
    movq $2, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .vm_safe_ret

# === Args Commands ===

# args_count - set current to number of runtime args
.ca_args_count:
    movq rt_args_count(%rip), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# args_get - get arg at index (current integer)
.ca_args_get:
    movq vm_cur_val(%rip), %rax
    leaq rt_args(%rip), %rdi
    movq (%rdi, %rax, 8), %rax
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# run_ca_string - parse current (string) as CA, run it in same VM context, merge defines; result stays in current
.ca_run_ca_string:
    movq vm_cur_type(%rip), %rax
    cmpq $3, %rax                  # type 3 = string
    jne .ca_rcs_bad
    pushq %r12
    pushq %r14
    movq vm_cur_val(%rip), %rdi
    call strlen
    movq %rax, %r12                 # r12 = length
    leaq module_parse_buf(%rip), %r14
    movq vm_cur_val(%rip), %rdi
    movq %r12, %rsi
    movq %r14, %rdx
    call parse_ca_to
    leaq 16(%r14), %rdi             # tree_base (skip BLOCK_START)
    call vm_collect_labels_from
    movq vm_run_sp(%rip), %rcx
    leaq vm_run_stack(%rip), %rdx
    movq %r13, (%rdx, %rcx, 8)
    incq %rcx
    movq %rcx, vm_run_sp(%rip)
    leaq 16(%r14), %r13
    popq %r14
    popq %r12
    jmp .vm_loop
.ca_rcs_bad:
    jmp .vm_safe_ret

# === Additional I/O Commands ===

# print_newline
.ca_print_nl:
    call print_newline
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret

# === Memory Commands ===

# heap_alloc - allocate current integer bytes (zeroed), return pointer
.ca_heap_alloc:
    movq vm_cur_val(%rip), %rdi
    call heap_alloc_zero
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# poke8 - write current value (8 bytes) to address popped from stack
.ca_poke8:
    movq vm_cur_val(%rip), %rax
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_poke_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rdi
    shlq $4, %rcx
    movq 8(%rdi, %rcx), %rdi
    movq %rax, (%rdi)
.ca_poke_done:
    jmp .vm_safe_ret

# peek8 - read 8 bytes from address (current integer)
.ca_peek8:
    movq vm_cur_val(%rip), %rdi
    movq (%rdi), %rax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# === New Map Commands ===

# map_has_dynamic - pop key, check if exists in current map, set compare flag
.ca_map_hasd:
    movq vm_cur_val(%rip), %rdi     # map
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mhd_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rsi       # key string
    call vm_map_has
    movq %rax, vm_comp_flag(%rip)
.ca_mhd_done:
    jmp .vm_safe_ret

# map_length_entries - get entry count of current map as integer
.ca_map_len:
    movq vm_cur_val(%rip), %rdi
    call vm_map_length
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# map_key_at - current int is index, pop map, return key string
.ca_map_key_at:
    movq vm_cur_val(%rip), %rsi     # index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mka_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # map pointer
    call vm_map_key_at
    testq %rax, %rax
    jz .ca_mka_undef
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_mka_undef:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
.ca_mka_done:
    jmp .vm_safe_ret

# map_type_at - current int is index, pop map, return entry type as int
.ca_map_type_at:
    movq vm_cur_val(%rip), %rsi     # index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mta_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # map pointer
    call vm_map_type_at
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_mta_done:
    jmp .vm_safe_ret

# map_val_at - current int is index, pop map, return entry value
.ca_map_val_at:
    movq vm_cur_val(%rip), %rsi     # index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mva_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # map pointer
    # Get both type and value for this entry
    pushq %rdi
    pushq %rsi
    call vm_map_type_at
    movq %rax, %r8                  # save type
    popq %rsi
    popq %rdi
    call vm_map_val_at
    movq %r8, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_mva_done:
    jmp .vm_safe_ret

# map_delete - pop key string, delete from current map
.ca_map_del:
    movq vm_cur_val(%rip), %rdi     # map
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mdel_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rsi       # key string
    call vm_map_delete
.ca_mdel_done:
    jmp .vm_safe_ret

# map_copy - pop dest map, copy all entries from current map to dest
.ca_map_cpy:
    movq vm_cur_val(%rip), %rsi     # src map (current)
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_mcp_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # dest map
    call vm_map_copy
.ca_mcp_done:
    jmp .vm_safe_ret

# === New Syscall Commands ===

# sys_getcwd - get current working directory as string
.ca_sys_getcwd:
    movq $4096, %rdi
    call heap_alloc
    movq %rax, %rbx
    movq %rax, %rdi
    movq $4096, %rsi
    call sys_getcwd
    movq $3, vm_cur_type(%rip)
    movq %rbx, vm_cur_val(%rip)
    jmp .vm_safe_ret

# sys_getdents - read directory entries
# current val = fd (int), result = array of name strings
.ca_sys_getdents:
    movq vm_cur_val(%rip), %rdi     # fd
    pushq %rdi
    # Allocate buffer for getdents64
    movq $32768, %rdi
    call heap_alloc
    movq %rax, %r8                  # buffer
    popq %rdi
    movq %r8, %rsi
    movq $32768, %rdx
    pushq %r8
    call sys_getdents64
    popq %r8
    # rax = bytes read (or negative on error)
    testq %rax, %rax
    jle .ca_sgd_empty
    movq %rax, %r9                  # total bytes
    # Create array to hold names
    pushq %r8
    pushq %r9
    call vm_array_new
    movq %rax, %r10                 # result array
    popq %r9
    popq %r8
    # Parse dirent64 entries
    xorq %rcx, %rcx                # offset
.ca_sgd_loop:
    cmpq %r9, %rcx
    jge .ca_sgd_ret
    leaq (%r8, %rcx), %rdi
    # d_reclen at offset 16 (2 bytes)
    movzwq 16(%rdi), %rax
    pushq %rax                     # save reclen
    pushq %rcx                     # save offset
    pushq %r8
    pushq %r9
    pushq %r10
    # d_name at offset 19
    leaq 19(%rdi), %rdi
    # Skip . and ..
    cmpb $46, (%rdi)
    jne .ca_sgd_add
    cmpb $0, 1(%rdi)
    je .ca_sgd_skip
    cmpb $46, 1(%rdi)
    jne .ca_sgd_add
    cmpb $0, 2(%rdi)
    je .ca_sgd_skip
.ca_sgd_add:
    call strdup
    movq %rax, %rdx                # value = string ptr
    movq $3, %rsi                  # type = string
    movq %r10, %rdi                # array
    call vm_array_push
.ca_sgd_skip:
    popq %r10
    popq %r9
    popq %r8
    popq %rcx
    popq %rax
    addq %rax, %rcx
    jmp .ca_sgd_loop
.ca_sgd_ret:
    movq $5, vm_cur_type(%rip)
    movq %r10, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_sgd_empty:
    call vm_array_new
    movq $5, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# sys_epoch - set current to seconds since epoch (number)
.ca_sys_epoch:
    call gettimeofday_sec
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# sys_date_string - set current to locale-formatted date string (matches Node toLocaleString)
.ca_sys_date_string:
    call run_date_string
    testq %rax, %rax
    jz .ca_sds_fail
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_sds_fail:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    jmp .vm_safe_ret

# sys_local_minutes - set current to local minutes (0-59), matches Node getMinutes()
.ca_sys_local_minutes:
    call run_local_minutes
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# sys_stat_file - stat a file path (current string)
# Sets current to map with mode field, or undefined on error
.ca_sys_stat_f:
    subq $256, %rsp                # stat buffer (144 bytes needed on x86_64)
    movq vm_cur_val(%rip), %rdi
    movq %rsp, %rsi
    call sys_stat
    testq %rax, %rax
    js .ca_ssf_err
    # st_mode is at offset 24 (4 bytes)
    movl 24(%rsp), %eax
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    addq $256, %rsp
    jmp .vm_safe_ret
.ca_ssf_err:
    movq $0, vm_cur_type(%rip)
    movq $0, vm_cur_val(%rip)
    addq $256, %rsp
    jmp .vm_safe_ret

# === New String Commands ===

# string_index_of - pop haystack from stack, find current string in it
# returns index (int) or -1
.ca_str_indexof:
    movq vm_cur_val(%rip), %rsi     # needle (current)
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_sio_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # haystack
    call strstr
    movq $2, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_sio_done:
    jmp .vm_safe_ret

# string_ends_with - pop string from stack, check if ends with current string
# returns 1/0 in compare flag
.ca_str_endswith:
    movq vm_cur_val(%rip), %rsi     # suffix (current)
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_sew_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # string
    call str_ends_with
    movq %rax, vm_comp_flag(%rip)
.ca_sew_done:
    jmp .vm_safe_ret

# string_slice - pop start, pop string, slice from start to current (end)
# or: current=end, pop start, pop string
.ca_str_slice:
    movq vm_cur_val(%rip), %r8      # end index
    # Pop start index
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ssl_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %r9        # start index
    # Pop string
    movq vm_val_sp(%rip), %rcx
    testq %rcx, %rcx
    jz .ca_ssl_done
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # string ptr
    # Calculate length
    movq %r8, %rsi                  # end
    subq %r9, %rsi                  # length = end - start
    testq %rsi, %rsi
    jle .ca_ssl_empty
    addq %r9, %rdi                  # src = string + start
    call strdup_len
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret
.ca_ssl_empty:
    movq $1, %rdi
    call heap_alloc
    movb $0, (%rax)
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_ssl_done:
    jmp .vm_safe_ret

# str_concat - pop two strings from stack, concat, set as current
.ca_str_concat2:
    movq vm_val_sp(%rip), %rcx
    cmpq $2, %rcx
    jl .ca_sc2_done
    # Pop second string
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %r8        # s2
    # Pop first string
    movq vm_val_sp(%rip), %rcx
    decq %rcx
    movq %rcx, vm_val_sp(%rip)
    leaq vm_val_stack(%rip), %rax
    shlq $4, %rcx
    movq 8(%rax, %rcx), %rdi       # s1
    movq %r8, %rsi                  # s2
    call str_concat
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
.ca_sc2_done:
    jmp .vm_safe_ret

# str_dup - duplicate current string (heap copy)
.ca_str_dup:
    movq vm_cur_val(%rip), %rdi
    call strdup
    movq $3, vm_cur_type(%rip)
    movq %rax, vm_cur_val(%rip)
    jmp .vm_safe_ret

# === VM Helper Functions ===

# vm_parse_int(str=%rdi) -> value in %rax, valid flag in %rdx (1=valid, 0=not)
vm_parse_int:
    pushq %rbx
    xorq %rax, %rax
    xorq %rdx, %rdx
    testq %rdi, %rdi
    jz .vpi_nan
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
    jmp .vm_safe_ret
.vpi_nan:
    xorq %rax, %rax
    xorq %rdx, %rdx
    jmp .vm_safe_ret

# vm_collect_labels - first pass: find label and define statements
# Scans through entire tree including inside define blocks (tracking depth)
vm_collect_labels:
    pushq %rbx
    pushq %r14
    pushq %r15
    movq %r12, %r14
    xorq %r15, %r15            # r15 = nesting depth (0 = top level)
    jmp .vcl_loop

# vm_collect_labels_from(tree_base=%rdi) - same but start from given tree (merge into vm_procs/vm_labels)
vm_collect_labels_from:
    pushq %rbx
    pushq %r14
    pushq %r15
    movq %rdi, %r14
    xorq %r15, %r15
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
    jmp .vm_safe_ret
.vfl_notfound:
    xorq %rax, %rax
    jmp .vm_safe_ret

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
    jmp .vm_safe_ret
.vfp_notfound:
    xorq %rax, %rax
    jmp .vm_safe_ret
'
