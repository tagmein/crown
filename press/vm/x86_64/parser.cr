# CrownAssembly (.ca) file parser
# Same lexical rules as Crown: spaces, newlines, commas, #comments,
# 'strings' with \\ and \' escapes, [blocks], (macros)
#
# Parse tree node format (16 bytes each):
#   type (8 bytes) + value (8 bytes, pointer to string or 0)
# Node types:
#   0 = END, 1 = BLOCK_START, 2 = BLOCK_END, 3 = STMT_END
#   4 = TOKEN_WORD, 5 = TOKEN_STRING
#   6 = MACRO_START, 7 = MACRO_END
#
# IMPORTANT: [blocks] are inline within statements (not separated by STMT_END).
# This matches Crown's behavior where [block] is an argument to the preceding command.

get emit_bss, call '    .lcomm token_buf, 4096
    .lcomm token_len, 8
    .lcomm parse_state, 8
    .lcomm parse_tree, 2097152
    .lcomm parse_node_count, 8
    .lcomm parse_output_ptr, 8
    .lcomm parse_has_tokens, 8
    .lcomm cr_parse_tree, 2097152
    .lcomm cr_node_count, 8'

get emit_text, call '# === CrownAssembly Parser ===

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

# parse_ca_to(input=%rdi, length=%rsi, output=%rdx) -> node count in %rax
# Parses CA into the given buffer (for run_ca_string / module loading)
parse_ca_to:
    call parse_common
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
    ret'
