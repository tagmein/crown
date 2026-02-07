# Press - x86-64 Crown VM Builder
# Generates crown-x86_64 native executable
#
# This file is Crown. When you run: ./crown press/main.cr
# Crown executes this code. The VM modules (loaded below) are also Crown;
# they call emit_data/emit_bss/emit_text with string literals whose content
# is assembly. Crown never executes that assembly — it only appends those
# strings to section buffers, then we write crown-x86_64.s and run as + ld.
#
# Platform-specific assembly lives under vm/<arch>/ (only vm/x86_64 for now).

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

# Load x86-64 VM modules (order: utilities first, entry last)
load vm/x86_64/syscalls.cr, point
load vm/x86_64/strings.cr, point
load vm/x86_64/memory.cr, point
load vm/x86_64/data-structures.cr, point
load vm/x86_64/parser.cr, point
load vm/x86_64/interpreter.cr, point
load vm/x86_64/entry.cr, point

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

# Assemble and link (-g so the binary can be debugged with the .s file as source)
get child_process execSync, call 'as -g -o crown-x86_64.o crown-x86_64.s 2>&1'
get child_process execSync, call 'ld -o crown-x86_64 crown-x86_64.o 2>&1'

# Clean up object file
get fs unlink, call crown-x86_64.o

log Press: Built crown-x86_64
