#!/usr/bin/env bash
# Run Crown tests under the native VM with a memory limit so the process
# exits with "heap allocation failed" instead of being killed by the system
# (which can take down Cursor or the whole machine).
#
# Usage:
#   ./scripts/run-vm-tests.sh [TEST_FILTER=path]
#   ./scripts/run-vm-tests.sh
#   TEST_FILTER=commands ./scripts/run-vm-tests.sh
#
# Default memory limit: 512 MB (override with CROWN_VM_MAX_MEMORY_MB or script arg).
# Build first: ./crown press/main.cr
#
# Debugging memory:
#   RUN_VM_DEBUG_MEM=1 ./scripts/run-vm-tests.sh
#     Runs under /usr/bin/time -v and prints max resident set size (RSS) and other stats.
#   On OOM the VM prints "requested N bytes, heap used: M bytes" so you see total heap at failure.
#   To see how far you get before OOM, use a higher limit and watch "heap used" in the error:
#     CROWN_VM_MAX_MEMORY_MB=1024 ./scripts/run-vm-tests.sh 1024

set -e
cd "$(dirname "$0")/.."

MB=${CROWN_VM_MAX_MEMORY_MB:-512}
if [[ $1 =~ ^[0-9]+$ ]]; then
  MB=$1
  shift
fi

export CROWN_VM_MAX_MEMORY_MB=$MB
CMD=(./scripts/run-vm-with-mem-limit.sh "$MB" -- ./crown-x86_64 -0 ./engines/a.ca -- tests.cr)
if [[ -n "${RUN_VM_DEBUG_MEM:-}" ]]; then
  exec /usr/bin/time -v "${CMD[@]}"
else
  exec "${CMD[@]}"
fi
