# Press — Crown VM builder

Press is **Crown code** that runs under the Crown interpreter (`./crown`) and **emits** a single assembly source file, which is then assembled and linked into the native binary `crown-x86_64`.

## How it works

1. **You run:** `./crown press/main.cr`
2. **Crown** executes `main.cr` (Crown syntax: `set`, `get`, `load`, `call`, `function`, `object`, `template`, etc.).
3. **main.cr** defines three buffers (`asm.data`, `asm.bss`, `asm.text`) and helpers:
   - `emit_data(s)` — append string `s` to the `.data` section
   - `emit_bss(s)`  — append to `.bss`
   - `emit_text(s)` — append to `.text`
4. **main.cr** loads platform-specific modules, e.g. `load vm/x86_64/syscalls.cr, point`. Those files are **also Crown**. They look like:

   ```crown
   get emit_text, call '# === Syscall Wrappers ===
   sys_write:
       movq $1, %rax
       ...
   '
   ```

   So: Crown syntax on the outside (`get emit_text, call [ ... ]`), and the **argument to `call`** is a Crown **string literal** whose **content** is assembly (GAS x86-64). Crown never executes that assembly; it just passes the string to `emit_text`, which appends it to the `.text` buffer.
5. After all modules run, **main.cr** joins the three sections into one source string and writes `crown-x86_64.s`, then runs `as` and `ld` to produce `crown-x86_64`.

So: **Press = Crown program**. The assembly is **data** (string contents) that gets written to a file. One platform = one folder under `vm/` (e.g. `vm/x86_64/`); we only support x86-64 for now.

## Layout

- **press/main.cr** — Crown entry; defines emit helpers, loads platform modules, writes `.s` and runs `as`/`ld`.
- **press/vm/x86_64/** — x86-64-only assembly (inside Crown string literals). One file per “module” (syscalls, strings, memory, data-structures, parser, interpreter, entry). Other platforms (e.g. arm64) would get their own `vm/<arch>/` later.
