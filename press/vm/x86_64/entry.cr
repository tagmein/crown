# VM Entry Point - _start, argument parsing, dispatch
# Emits: data (banner, usage, strings), bss (state), text (_start + helpers)
#
# Argument parsing uses -- separator:
#   Before --: .ca files to execute
#   After --:  runtime arguments (accessible via args_count/args_get)
#
# Options (before --):
#   -0, --zero    Suppress startup banner
#
# Examples:
#   ./crown-x86_64 file.ca                    # run one CA file
#   ./crown-x86_64 a.ca b.ca                  # run multiple CA files
#   ./crown-x86_64 engine.ca -- file.cr       # engine + runtime args
#   ./crown-x86_64 -0 engine.ca -- file.cr    # silent mode

get emit_data, call 'banner:
    .ascii "crown-x86_64 v0.1.0\\n"
    .set banner_len, . - banner
usage_msg:
    .ascii "Usage: crown-x86_64 [file.ca ...] [-- args...]\\n"
    .set usage_len, . - usage_msg
dashdash:
    .asciz "--"
newline_char:
    .byte 10
err_no_files:
    .asciz "Error: no .ca files specified\\n"
err_open_fail:
    .asciz "Error: cannot open file\\n"
opt_zero_short:
    .asciz "-0"
opt_zero_long:
    .asciz "--zero"
default_engine:
    .asciz "engines/a.ca"
default_repl:
    .asciz "repl.cr"'

get emit_bss, call '    .lcomm saved_rsp, 8
    .lcomm saved_envp, 8
    .lcomm ca_files, 2048
    .lcomm ca_file_count, 8
    .lcomm rt_args, 2048
    .lcomm rt_args_count, 8
    .lcomm file_buffer, 1048576
    .lcomm file_size, 8
    .lcomm banner_suppress, 8'

get emit_text, call '.globl _start
_start:
    # Save initial stack pointer (argc/argv access)
    movq %rsp, saved_rsp(%rip)
    # Save envp for execve (envp = rsp + 8*(argc+2))
    movq (%rsp), %rcx
    leaq 16(%rsp, %rcx, 8), %rax
    movq %rax, saved_envp(%rip)

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
    pushq %r12
    # Open file (O_RDONLY = 0)
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    call sys_open
    testq %rax, %rax
    js .lf_fail
    movq %rax, %rbx               # save fd
    xorq %r12, %r12               # r12 = total bytes read
.lf_read_loop:
    movq %rbx, %rdi
    leaq file_buffer(%rip), %rsi
    addq %r12, %rsi
    movq $1048575, %rdx
    subq %r12, %rdx
    testq %rdx, %rdx
    jle .lf_read_done
    call sys_read
    testq %rax, %rax
    js .lf_fail_close
    jz .lf_read_done               # EOF
    addq %rax, %r12
    jmp .lf_read_loop
.lf_read_done:
    movq %r12, file_size(%rip)
    # Null-terminate the buffer
    leaq file_buffer(%rip), %rdi
    movb $0, (%rdi, %r12)
    # Close file
    movq %rbx, %rdi
    call sys_close
    xorq %rax, %rax
    popq %r12
    popq %rbx
    ret
.lf_fail_close:
    movq %rbx, %rdi
    call sys_close
.lf_fail:
    movq $-1, %rax
    popq %r12
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
    ret'
