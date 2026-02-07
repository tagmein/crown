# Crown Language Runtime
# Parses and executes .cr files using the VM's parser and data structures
#
# Crown commands implemented:
#   Stage 6a: value, log, set, get, add, subtract, multiply, divide, template
#   Stage 6b: function, call, to, at, list, object, true, false, pick, clone,
#             load, point, current
#   Stage 6c: each, map, filter, find, loop, try, error, not, all, any,
#             comparisons (<, >, <=, >=, =), drop, keep, scope, run, default,
#             typeof, is, names, unset, do, comment, prepend

get emit_bss, call '    .lcomm cr_scope, 8
    .lcomm cr_cur_type, 8
    .lcomm cr_cur_val, 8
    .lcomm cr_call_stack, 32768
    .lcomm cr_call_sp, 8'

get emit_data, call 'cr_cmd_value:      .asciz "value"
cr_cmd_log:        .asciz "log"
cr_cmd_set:        .asciz "set"
cr_cmd_get:        .asciz "get"
cr_cmd_add:        .asciz "add"
cr_cmd_subtract:   .asciz "subtract"
cr_cmd_multiply:   .asciz "multiply"
cr_cmd_divide:     .asciz "divide"
cr_cmd_template:   .asciz "template"
cr_cmd_function:   .asciz "function"
cr_cmd_call:       .asciz "call"
cr_cmd_to:         .asciz "to"
cr_cmd_at:         .asciz "at"
cr_cmd_true:       .asciz "true"
cr_cmd_false:      .asciz "false"
cr_cmd_pick:       .asciz "pick"
cr_cmd_current:    .asciz "current"
cr_cmd_list:       .asciz "list"
cr_cmd_comment:    .asciz "comment"
cr_cmd_load:       .asciz "load"
cr_cmd_point:      .asciz "point"
cr_scope_parent:   .asciz "__parent__"
cr_unknown:        .asciz "Unknown Crown command: "
cr_squote:         .byte 39, 0
cr_template_buf:   .space 4096'

get emit_text, call '# === Crown Runtime ===

# cr_run_file(path=%rdi, scope=%rsi) - load, parse, and run a .cr file
# scope: map pointer (or 0 for new scope)
cr_run_file:
    pushq %rbx
    pushq %r12
    pushq %r13
    movq %rsi, %r13                # save scope

    # Load the file
    call load_file
    testq %rax, %rax
    js .crf_fail

    # Parse it
    leaq file_buffer(%rip), %rdi
    movq file_size(%rip), %rsi
    call parse_cr

    # Create scope if needed
    testq %r13, %r13
    jnz .crf_has_scope
    call vm_map_new
    movq %rax, %r13
.crf_has_scope:

    # Walk the parse tree
    leaq cr_parse_tree(%rip), %rdi
    addq $16, %rdi                 # skip initial BLOCK_START
    movq %r13, %rsi
    call cr_walk

    popq %r13
    popq %r12
    popq %rbx
    ret

.crf_fail:
    leaq err_open_fail(%rip), %rdi
    call print_cstring
    popq %r13
    popq %r12
    popq %rbx
    ret

# cr_walk(node_ptr=%rdi, scope=%rsi) -> type in cr_cur_type, value in cr_cur_val
# Walks a section of parse tree, executing Crown statements
cr_walk:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq %rdi, %r12                # r12 = current node pointer
    movq %rsi, %r13                # r13 = scope (map ptr)

.crw_loop:
    movq (%r12), %rax
    testq %rax, %rax
    jz .crw_done                   # END
    cmpq $2, %rax
    je .crw_done                   # BLOCK_END

    cmpq $3, %rax                  # STMT_END
    je .crw_skip_node

    cmpq $1, %rax                  # BLOCK_START (stray, skip)
    je .crw_skip_block

    cmpq $4, %rax                  # TOKEN_WORD
    je .crw_stmt
    cmpq $5, %rax                  # TOKEN_STRING
    je .crw_stmt

.crw_skip_node:
    addq $16, %r12
    jmp .crw_loop

.crw_skip_block:
    addq $16, %r12
    movq $1, %rcx
.crw_sb_loop:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .crw_sb_ns
    incq %rcx
    jmp .crw_sb_loop
.crw_sb_ns:
    cmpq $2, %rax
    jne .crw_sb_loop
    decq %rcx
    jnz .crw_sb_loop
    jmp .crw_loop

.crw_stmt:
    movq 8(%r12), %rdi             # command name
    addq $16, %r12                 # past command token
    movq %r12, %rsi                # args start
    movq %r13, %rdx                # scope
    call cr_dispatch

    # Skip to STMT_END (handle nested blocks)
.crw_skip_stmt:
    movq (%r12), %rax
    cmpq $3, %rax
    je .crw_past_stmt
    cmpq $0, %rax
    je .crw_done
    cmpq $2, %rax
    je .crw_done
    cmpq $1, %rax
    jne .crw_ss_next
    # Skip nested block
    addq $16, %r12
    movq $1, %rcx
.crw_ss_block:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .crw_ss_bns
    incq %rcx
    jmp .crw_ss_block
.crw_ss_bns:
    cmpq $2, %rax
    jne .crw_ss_block
    decq %rcx
    jnz .crw_ss_block
    jmp .crw_skip_stmt
.crw_ss_next:
    addq $16, %r12
    jmp .crw_skip_stmt
.crw_past_stmt:
    addq $16, %r12
    jmp .crw_loop

.crw_done:
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    ret

# cr_dispatch(cmd=%rdi, args=%rsi (node_ptr), scope=%rdx)
# Updates r12 (node pointer) as args are consumed
cr_dispatch:
    pushq %rbx
    pushq %r14
    pushq %r15
    movq %rdi, %rbx                # command name
    movq %rsi, %r12                # args (updates r12)
    movq %rdx, %r15                # scope

    # --- value ---
    leaq cr_cmd_value(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_value

    # --- log ---
    leaq cr_cmd_log(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_log

    # --- set ---
    leaq cr_cmd_set(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_set

    # --- get ---
    leaq cr_cmd_get(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_get

    # --- add ---
    leaq cr_cmd_add(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_add

    # --- subtract ---
    leaq cr_cmd_subtract(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_subtract

    # --- multiply ---
    leaq cr_cmd_multiply(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_multiply

    # --- divide ---
    leaq cr_cmd_divide(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_divide

    # --- template ---
    leaq cr_cmd_template(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_template

    # --- function ---
    leaq cr_cmd_function(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_function

    # --- call ---
    leaq cr_cmd_call(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_call

    # --- to ---
    leaq cr_cmd_to(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_to

    # --- true ---
    leaq cr_cmd_true(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_true

    # --- false ---
    leaq cr_cmd_false(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_false

    # --- pick ---
    leaq cr_cmd_pick(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_pick

    # --- current ---
    leaq cr_cmd_current(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_current

    # --- comment ---
    leaq cr_cmd_comment(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_comment

    # --- load ---
    leaq cr_cmd_load(%rip), %rsi
    movq %rbx, %rdi
    call strcmp
    testq %rax, %rax
    jz .cr_load

    # --- Unknown: try as variable get ---
    movq %r15, %rdi
    movq %rbx, %rsi
    call vm_map_get
    testq %rax, %rax
    jnz .cr_implicit_get

    # Really unknown
    leaq cr_unknown(%rip), %rdi
    call print_cstring
    movq %rbx, %rdi
    call print_cstring
    call print_newline
    popq %r15
    popq %r14
    popq %rbx
    ret

.cr_implicit_get:
    # Bare word that matches a variable name - act as get
    movq %rax, cr_cur_type(%rip)
    movq %rdx, cr_cur_val(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# === Crown Command Implementations ===

# value <literal> - set current value
.cr_value:
    movq (%r12), %rax
    cmpq $3, %rax
    je .cr_val_done
    cmpq $4, %rax
    je .cr_val_word
    cmpq $5, %rax
    je .cr_val_str
    jmp .cr_val_done
.cr_val_word:
    movq 8(%r12), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .cr_val_word_str
    movq $2, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
    jmp .cr_val_done
.cr_val_word_str:
    movq 8(%r12), %rax
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
    jmp .cr_val_done
.cr_val_str:
    movq 8(%r12), %rax
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
.cr_val_done:
    popq %r15
    popq %r14
    popq %rbx
    ret

# log [args...] - print args or current value with newline
.cr_log:
    movq (%r12), %rax
    cmpq $3, %rax
    je .cr_log_cur
    cmpq $0, %rax
    je .cr_log_cur
    cmpq $2, %rax
    je .cr_log_cur

    # Check if first arg is a block - evaluate it
    cmpq $1, %rax
    je .cr_log_block

.cr_log_args:
    movq (%r12), %rax
    cmpq $3, %rax
    je .cr_log_nl
    cmpq $0, %rax
    je .cr_log_nl
    cmpq $2, %rax
    je .cr_log_nl
    cmpq $1, %rax
    je .cr_log_eval_block
    cmpq $4, %rax
    je .cr_log_print_token
    cmpq $5, %rax
    je .cr_log_print_token
    addq $16, %r12
    jmp .cr_log_args
.cr_log_print_token:
    movq 8(%r12), %rdi
    call print_cstring
    addq $16, %r12
    movq (%r12), %rax
    cmpq $3, %rax
    je .cr_log_nl
    cmpq $0, %rax
    je .cr_log_nl
    cmpq $2, %rax
    je .cr_log_nl
    cmpq $1, %rax
    je .cr_log_args
    leaq ca_space(%rip), %rdi
    call print_cstring
    jmp .cr_log_args
.cr_log_eval_block:
    # Evaluate block and print result
    addq $16, %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    # Skip to matching BLOCK_END in r12
    movq $1, %rcx
.cr_log_eb_skip:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cr_log_eb_ns
    incq %rcx
    jmp .cr_log_eb_skip
.cr_log_eb_ns:
    cmpq $2, %rax
    jne .cr_log_eb_skip
    decq %rcx
    jnz .cr_log_eb_skip
    # Print the result
    call cr_print_current
    jmp .cr_log_args

.cr_log_block:
    # Evaluate block as the sole argument
    addq $16, %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    # Skip to matching BLOCK_END
    movq $1, %rcx
.cr_log_bskip:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cr_log_bns
    incq %rcx
    jmp .cr_log_bskip
.cr_log_bns:
    cmpq $2, %rax
    jne .cr_log_bskip
    decq %rcx
    jnz .cr_log_bskip
    call cr_print_current
    jmp .cr_log_nl

.cr_log_nl:
    call print_newline
    popq %r15
    popq %r14
    popq %rbx
    ret
.cr_log_cur:
    call cr_print_current
    call print_newline
    popq %r15
    popq %r14
    popq %rbx
    ret

# set <name> <value or [block]> - define variable in scope
.cr_set:
    # Get variable name
    movq 8(%r12), %r14             # variable name
    addq $16, %r12
    # Get value
    movq (%r12), %rax
    cmpq $1, %rax                  # BLOCK_START - evaluate
    je .cr_set_block
    cmpq $4, %rax
    je .cr_set_token
    cmpq $5, %rax
    je .cr_set_str
    jmp .cr_set_store
.cr_set_block:
    addq $16, %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    # Skip block in r12
    movq $1, %rcx
.cr_set_bs:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cr_set_bns
    incq %rcx
    jmp .cr_set_bs
.cr_set_bns:
    cmpq $2, %rax
    jne .cr_set_bs
    decq %rcx
    jnz .cr_set_bs
    jmp .cr_set_store
.cr_set_token:
    movq 8(%r12), %rdi
    call vm_parse_int
    testq %rdx, %rdx
    jz .cr_set_token_str
    movq $2, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
    jmp .cr_set_store
.cr_set_token_str:
    movq 8(%r12), %rax
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
    jmp .cr_set_store
.cr_set_str:
    movq 8(%r12), %rax
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $16, %r12
.cr_set_store:
    movq %r15, %rdi
    movq %r14, %rsi
    movq cr_cur_type(%rip), %rdx
    movq cr_cur_val(%rip), %rcx
    call vm_map_set
    popq %r15
    popq %r14
    popq %rbx
    ret

# get <name> [property...] - read variable from scope
.cr_get:
    movq 8(%r12), %rsi
    addq $16, %r12
    # Search scope chain
    movq %r15, %rdi
    call cr_scope_get
    movq %rax, cr_cur_type(%rip)
    movq %rdx, cr_cur_val(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# add <value or [block]> - arithmetic add
.cr_add:
    movq cr_cur_val(%rip), %r14    # save current value
    call cr_eval_arg               # %rax = arg (clobbers cr_cur_val)
    addq %r14, %rax
    movq %rax, cr_cur_val(%rip)
    movq $2, cr_cur_type(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# subtract <value>
.cr_subtract:
    movq cr_cur_val(%rip), %r14
    call cr_eval_arg
    subq %rax, %r14
    movq %r14, cr_cur_val(%rip)
    movq $2, cr_cur_type(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# multiply <value>
.cr_multiply:
    movq cr_cur_val(%rip), %r14
    call cr_eval_arg
    imulq %r14, %rax
    movq %rax, cr_cur_val(%rip)
    movq $2, cr_cur_type(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# divide <value>
.cr_divide:
    movq cr_cur_val(%rip), %r14
    call cr_eval_arg
    movq %rax, %rcx
    testq %rcx, %rcx
    jz .cr_div_zero
    movq %r14, %rax
    cqto
    idivq %rcx
    movq %rax, cr_cur_val(%rip)
    movq $2, cr_cur_type(%rip)
.cr_div_zero:
    popq %r15
    popq %r14
    popq %rbx
    ret

# template <format> [args...] - string formatting
# Pre-evaluates all args, then substitutes %0, %1, etc.
.cr_template:
    movq 8(%r12), %r14             # format string
    addq $16, %r12

    # Pre-evaluate up to 10 args onto stack (type+value pairs)
    subq $160, %rsp                # 10 * 16 bytes
    xorq %rbx, %rbx                # arg count
.cr_tmpl_eval:
    movq (%r12), %rax
    cmpq $3, %rax
    je .cr_tmpl_eval_done
    cmpq $0, %rax
    je .cr_tmpl_eval_done
    cmpq $2, %rax
    je .cr_tmpl_eval_done
    pushq %rbx
    call cr_eval_arg
    popq %rbx
    movq %rbx, %rax
    shlq $4, %rax
    # Buffer starts at 8(%rsp) (below saved_rbx); do not overwrite return address
    movq cr_cur_type(%rip), %rcx
    movq %rcx, 8(%rsp, %rax)
    movq cr_cur_val(%rip), %rcx
    movq %rcx, 16(%rsp, %rax)
    incq %rbx
    jmp .cr_tmpl_eval
.cr_tmpl_eval_done:

    # Now format: scan format string, substitute %N with pre-evaluated args
    leaq cr_template_buf(%rip), %rdi
    xorq %rcx, %rcx                # output index
    xorq %rbx, %rbx                # input index
.cr_tmpl_loop:
    movb (%r14, %rbx), %al
    testb %al, %al
    jz .cr_tmpl_done
    cmpb $37, %al
    je .cr_tmpl_percent
    movb %al, (%rdi, %rcx)
    incq %rbx
    incq %rcx
    jmp .cr_tmpl_loop
.cr_tmpl_percent:
    incq %rbx
    movb (%r14, %rbx), %al
    testb %al, %al
    jz .cr_tmpl_done
    movzbq %al, %rax
    subq $48, %rax                 # arg index (0-9)
    incq %rbx
    # Look up pre-evaluated arg on stack (buffer at 8(%rsp))
    shlq $4, %rax
    movq 8(%rsp, %rax), %rdx      # type
    movq 16(%rsp, %rax), %rsi     # value
    cmpq $2, %rdx
    je .cr_tmpl_int
    cmpq $3, %rdx
    je .cr_tmpl_str
    jmp .cr_tmpl_loop
.cr_tmpl_int:
    # Convert integer to string and append
    pushq %rbx
    pushq %rcx
    pushq %rdi
    pushq %r14
    movq %rsi, %rdi
    subq $32, %rsp
    movq %rsp, %rsi
    call itoa
    movq %rax, %rdx
    movq %rsp, %rsi
    addq $32, %rsp
    popq %r14
    popq %rdi
    popq %rcx
    popq %rbx
    xorq %r8, %r8
.cr_tmpl_copy_int:
    cmpq %rdx, %r8
    jge .cr_tmpl_loop
    movb (%rsi, %r8), %al
    movb %al, (%rdi, %rcx)
    incq %r8
    incq %rcx
    jmp .cr_tmpl_copy_int
.cr_tmpl_str:
    pushq %rbx
    xorq %r8, %r8
.cr_tmpl_copy_str:
    movb (%rsi, %r8), %al
    testb %al, %al
    jz .cr_tmpl_str_done
    movb %al, (%rdi, %rcx)
    incq %r8
    incq %rcx
    jmp .cr_tmpl_copy_str
.cr_tmpl_str_done:
    popq %rbx
    jmp .cr_tmpl_loop
.cr_tmpl_done:
    movb $0, (%rdi, %rcx)
    # Duplicate result to heap
    pushq %rcx
    leaq cr_template_buf(%rip), %rdi
    movq %rcx, %rsi
    call strdup_len
    popq %rcx
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    addq $160, %rsp                # clean up pre-evaluated args
    popq %r15
    popq %r14
    popq %rbx
    ret

# function [...args] [body] - no automatic walk, store as closure
.cr_function:
    # Store pointer to current position + scope as function value
    # We use a simple representation: pair (node_ptr, scope_ptr)
    movq $24, %rdi
    call heap_alloc
    movq %r12, (%rax)              # node pointer (start of arg names / block)
    movq %r15, 8(%rax)             # captured scope
    movq $0, 16(%rax)              # placeholder
    movq $7, cr_cur_type(%rip)     # type 7 = function
    movq %rax, cr_cur_val(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# call [args...] - call function in current value
.cr_call:
    movq cr_cur_type(%rip), %rax
    cmpq $7, %rax
    jne .cr_call_done
    movq cr_cur_val(%rip), %r14    # function struct
    movq (%r14), %rbx              # node ptr to function definition
    movq 8(%r14), %r14             # captured scope
    # Create new scope with parent = captured scope
    pushq %rbx
    call vm_map_new
    movq %rax, %r13                # new scope
    movq %r13, %rdi
    leaq cr_scope_parent(%rip), %rsi
    movq $6, %rdx                  # type = map (scope)
    movq %r14, %rcx
    call vm_map_set
    popq %rbx
    # Bind arguments: read param names from function definition
    # Then read block body
    # Function format: function argname1 argname2 [body]
    movq %rbx, %r14                # scan function node ptr
.cr_call_bind:
    movq (%r14), %rax
    cmpq $4, %rax
    jne .cr_call_body
    # Param name
    movq 8(%r14), %rbx            # param name
    addq $16, %r14
    # Get corresponding argument (evaluate from r12)
    call cr_eval_arg
    # Store in new scope
    movq %r13, %rdi
    movq %rbx, %rsi
    movq cr_cur_type(%rip), %rdx
    movq cr_cur_val(%rip), %rcx
    call vm_map_set
    jmp .cr_call_bind
.cr_call_body:
    # r14 should point to BLOCK_START of function body
    cmpq $1, (%r14)
    jne .cr_call_done
    addq $16, %r14                 # past BLOCK_START
    # Walk function body with new scope
    movq %r14, %rdi
    movq %r13, %rsi
    call cr_walk
.cr_call_done:
    popq %r15
    popq %r14
    popq %rbx
    ret

# to <name> - store current value to variable
.cr_to:
    movq 8(%r12), %rsi
    addq $16, %r12
    movq %r15, %rdi
    movq cr_cur_type(%rip), %rdx
    movq cr_cur_val(%rip), %rcx
    call vm_map_set
    popq %r15
    popq %r14
    popq %rbx
    ret

# true [block] - if current value is truthy, evaluate block
.cr_true:
    movq (%r12), %rax
    cmpq $1, %rax
    jne .cr_true_val
    # Has block: evaluate if current is truthy
    movq cr_cur_type(%rip), %rax
    testq %rax, %rax
    jz .cr_true_skip               # undefined = falsy
    movq cr_cur_val(%rip), %rax
    testq %rax, %rax
    jz .cr_true_skip               # 0/null = falsy
    # Truthy: evaluate block
    addq $16, %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    jmp .cr_true_skip_block
.cr_true_skip:
    addq $16, %r12
.cr_true_skip_block:
    movq $1, %rcx
.cr_true_sb:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cr_true_sbns
    incq %rcx
    jmp .cr_true_sb
.cr_true_sbns:
    cmpq $2, %rax
    jne .cr_true_sb
    decq %rcx
    jnz .cr_true_sb
    popq %r15
    popq %r14
    popq %rbx
    ret
.cr_true_val:
    # No block: set current to boolean true (1)
    movq $4, cr_cur_type(%rip)
    movq $1, cr_cur_val(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# false
.cr_false:
    movq $4, cr_cur_type(%rip)
    movq $0, cr_cur_val(%rip)
    popq %r15
    popq %r14
    popq %rbx
    ret

# pick [block1] [block2] ... - conditional execution
.cr_pick:
    # Evaluate blocks in order. Each block starts with a condition.
    # First block whose condition is true: its value becomes current.
.cr_pick_loop:
    movq (%r12), %rax
    cmpq $1, %rax                  # BLOCK_START
    jne .cr_pick_done
    # Evaluate this block
    addq $16, %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    # Skip block in r12
    movq $1, %rcx
.cr_pick_skip:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cr_pick_sns
    incq %rcx
    jmp .cr_pick_skip
.cr_pick_sns:
    cmpq $2, %rax
    jne .cr_pick_skip
    decq %rcx
    jnz .cr_pick_skip
    jmp .cr_pick_loop
.cr_pick_done:
    popq %r15
    popq %r14
    popq %rbx
    ret

# current - return current value (no-op, value is already in cr_cur)
.cr_current:
    popq %r15
    popq %r14
    popq %rbx
    ret

# comment - skip everything (no-op)
.cr_comment:
    popq %r15
    popq %r14
    popq %rbx
    ret

# load <file> - load and execute a .cr file
.cr_load:
    movq 8(%r12), %rdi
    addq $16, %r12
    movq %r15, %rsi                # same scope
    call cr_run_file
    popq %r15
    popq %r14
    popq %rbx
    ret

# === Crown Helper Functions ===

# cr_print_current - print current value to stdout (no newline)
cr_print_current:
    movq cr_cur_type(%rip), %rax
    cmpq $2, %rax
    je .cpc_int
    cmpq $3, %rax
    je .cpc_str
    cmpq $4, %rax
    je .cpc_bool
    ret
.cpc_int:
    movq cr_cur_val(%rip), %rdi
    call print_number
    ret
.cpc_str:
    leaq cr_squote(%rip), %rdi
    call print_cstring
    movq cr_cur_val(%rip), %rdi
    call print_cstring
    leaq cr_squote(%rip), %rdi
    call print_cstring
    ret
.cpc_bool:
    movq cr_cur_val(%rip), %rax
    testq %rax, %rax
    jz .cpc_false
    leaq cr_cmd_true(%rip), %rdi
    call print_cstring
    ret
.cpc_false:
    leaq cr_cmd_false(%rip), %rdi
    call print_cstring
    ret

# cr_scope_get(scope=%rdi, name=%rsi) -> type in %rax, value in %rdx
# Searches scope chain (follows __parent__ links)
cr_scope_get:
    pushq %rbx
    pushq %r12
    movq %rdi, %r12                # current scope
    movq %rsi, %rbx                # name
.csg_loop:
    testq %r12, %r12
    jz .csg_notfound
    movq %r12, %rdi
    movq %rbx, %rsi
    call vm_map_get
    testq %rax, %rax
    jnz .csg_found
    # Try parent scope
    movq %r12, %rdi
    leaq cr_scope_parent(%rip), %rsi
    call vm_map_get
    cmpq $6, %rax                  # type = map
    jne .csg_notfound
    movq %rdx, %r12                # parent scope
    jmp .csg_loop
.csg_found:
    popq %r12
    popq %rbx
    ret
.csg_notfound:
    xorq %rax, %rax
    xorq %rdx, %rdx
    popq %r12
    popq %rbx
    ret

# cr_eval_arg - evaluate the next argument (token or block) from r12
# Returns numeric value in %rax (for arithmetic), updates cr_cur_*
cr_eval_arg:
    movq (%r12), %rax
    cmpq $1, %rax                  # BLOCK_START
    je .cea_block
    cmpq $4, %rax
    je .cea_word
    cmpq $5, %rax
    je .cea_str
    xorq %rax, %rax
    ret
.cea_block:
    addq $16, %r12
    pushq %r12
    movq %r12, %rdi
    movq %r15, %rsi
    call cr_walk
    popq %r12
    # Skip block
    movq $1, %rcx
.cea_bs:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cea_bns
    incq %rcx
    jmp .cea_bs
.cea_bns:
    cmpq $2, %rax
    jne .cea_bs
    decq %rcx
    jnz .cea_bs
    movq cr_cur_val(%rip), %rax
    ret
.cea_word:
    movq 8(%r12), %rdi
    addq $16, %r12
    call vm_parse_int
    testq %rdx, %rdx
    jz .cea_word_var
    movq $2, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    ret
.cea_word_var:
    # Try as variable lookup: %rdi still holds the word string
    movq %rdi, %rsi                # key = the word string
    movq %r15, %rdi                # scope
    call cr_scope_get
    testq %rax, %rax
    jnz .cea_word_found
    xorq %rax, %rax
    ret
.cea_word_found:
    movq %rax, cr_cur_type(%rip)
    movq %rdx, cr_cur_val(%rip)
    movq %rdx, %rax
    ret
.cea_str:
    movq 8(%r12), %rax
    addq $16, %r12
    movq $3, cr_cur_type(%rip)
    movq %rax, cr_cur_val(%rip)
    ret

# cr_eval_nth_arg(n=%rax) - evaluate the Nth argument from r14 (saved args pointer)
# Result in cr_cur_type/cr_cur_val
cr_eval_nth_arg:
    pushq %rbx
    pushq %r12
    pushq %r14
    movq %rax, %rbx                # target index
    movq %r14, %r12                # start of args
    xorq %rcx, %rcx                # current index
.cena_loop:
    cmpq %rbx, %rcx
    je .cena_found
    # Skip this arg
    movq (%r12), %rax
    cmpq $1, %rax
    je .cena_skip_block
    addq $16, %r12
    incq %rcx
    jmp .cena_loop
.cena_skip_block:
    addq $16, %r12
    movq $1, %rdx
.cena_sb:
    movq (%r12), %rax
    addq $16, %r12
    cmpq $1, %rax
    jne .cena_sbns
    incq %rdx
    jmp .cena_sb
.cena_sbns:
    cmpq $2, %rax
    jne .cena_sb
    decq %rdx
    jnz .cena_sb
    incq %rcx
    jmp .cena_loop
.cena_found:
    # Evaluate arg at r12
    call cr_eval_arg
    popq %r14
    popq %r12
    popq %rbx
    ret'
