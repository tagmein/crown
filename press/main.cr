# Press - x86-64 Crown VM Builder
# Generates crown-x86_64 native executable
#
# Output formats:
#   assembly_x86_64 (default): writes .s file, invokes as + ld
#   elf: generates ELF binary directly (Stage 8 - TODO)

set fs [ global import, call fs/promises ]
set child_process [ global import, call node:child_process ]

# Assembly section builders
set asm [ object [
  data [ list ]
  bss [ list ]
  text [ list ]
] ]

set emit_data [ function s [ get asm data push, call [ get s ] ] ]
set emit_bss [ function s [ get asm bss push, call [ get s ] ] ]
set emit_text [ function s [ get asm text push, call [ get s ] ] ]

# Load VM modules (order: utilities first, entry last)
load vm/syscalls.cr, point
load vm/strings.cr, point
load vm/memory.cr, point
load vm/data-structures.cr, point
load vm/parser.cr, point
load vm/interpreter.cr, point
load vm/entry.cr, point

# Newline for joining
set nl '
'

# Combine into final assembly source
set asm_source [ template '.section .data
%0

.section .bss
%1

.section .text
%2
' [ get asm data, at join, call [ get nl ] ] [ get asm bss, at join, call [ get nl ] ] [ get asm text, at join, call [ get nl ] ] ]

# Write assembly source
get fs writeFile, call crown-x86_64.s [ get asm_source ]

# Assemble and link
get child_process execSync, call 'as -o crown-x86_64.o crown-x86_64.s 2>&1'
get child_process execSync, call 'ld -o crown-x86_64 crown-x86_64.o 2>&1'

# Clean up object file
get fs unlink, call crown-x86_64.o

log Press: Built crown-x86_64
