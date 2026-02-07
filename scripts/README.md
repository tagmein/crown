# Scripts

## Root cause of VM OOM (vs Node: `./crown tests.cr` passes)

- **Node runtime** has a garbage collector; short-lived objects from each spec are reclaimed.
- **Native VM** (`crown-x86_64`) has **no GC**; every string, map, and array stays on the heap until process exit.
- **Code bugs (fixed):** The VM was also leaking large buffers in a few paths:
  - **crown_run_all**: main script file + tree buffers were never released → now we call `file_release` and `tree_release` after `crown_walk`.
  - **cr_load**: file content buffer was never released → we call `file_release` after building the closure; **cr_point** already called `tree_release`.
  - **cr_run** (Crown `run 'string'`): tree buffer was never released → we now call `tree_release` after the run.
- **How to confirm:** On OOM the VM prints `large (>=256KB) allocs: N`. If N is 2 (one file buffer + one tree buffer in reuse), the buffer leaks are fixed; the rest is small allocations with no GC.

## run-vm-tests.sh

Runs the Crown test suite under the native VM (`crown-x86_64`) with a **memory limit** so the process exits with a clear error instead of being killed by the system (which can crash the IDE or machine).

```bash
./scripts/run-vm-tests.sh
TEST_FILTER=commands ./scripts/run-vm-tests.sh
CROWN_VM_MAX_MEMORY_MB=1024 ./scripts/run-vm-tests.sh 1024
```

Build first: `./crown press/main.cr`

## run-vm-with-mem-limit.sh

Generic wrapper to run any command with a virtual memory limit (e.g. `ulimit -v`). Used by `run-vm-tests.sh`.

```bash
./scripts/run-vm-with-mem-limit.sh 256 -- ./crown-x86_64 -0 ./engines/a.ca -- my-script.cr
```

## Debugging memory usage

1. **Heap at OOM**  
   When the VM hits the memory limit it prints:
   ```text
   Error: heap allocation failed (requested N bytes, heap used: M bytes)
   ```
   So you see how much heap was in use when the allocation failed. That’s the VM’s brk heap only (no stack/static).

2. **Process RSS (resident set size)**  
   Run with `RUN_VM_DEBUG_MEM=1` to get `time -v` output, including **Maximum resident set size (kbytes)**:
   ```bash
   RUN_VM_DEBUG_MEM=1 ./scripts/run-vm-tests.sh
   ```
   That’s the peak memory of the whole process (heap + stack + code, as seen by the OS).

3. **Narrow where it fails**  
   Use a higher limit and watch the “heap used” value in the OOM message to see how far you get. Use `TEST_FILTER` to run a subset of tests and see which range of specs fits in a given limit.

4. **External tools (optional)**  
   - `heaptrack` (Linux): heap profiler; run `heaptrack ./crown-x86_64 ...` then inspect with `heaptrack_gui`.
   - `valgrind --tool=massif`: heap snapshot over time; `ms_print massif.out.*` for a text graph.
   These show allocations at the C/asm level, not per Crown operation.
