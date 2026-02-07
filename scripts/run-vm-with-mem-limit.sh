#!/usr/bin/env bash
# Run a command with a virtual memory limit so the process is killed (or fails
# with "heap allocation failed") when it exceeds the limit, instead of using
# all system memory and e.g. killing the host IDE.
#
# Usage:
#   ./scripts/run-vm-with-mem-limit.sh [MB] -- command [args...]
#   ./scripts/run-vm-with-mem-limit.sh 256 -- ./crown-x86_64 engines/a.ca -- tests.cr
#   ./scripts/run-vm-with-mem-limit.sh -- ./crown-x86_64 engines/a.ca -- tests.cr
#
# If the first argument is a number, it is the limit in MB (default 256).
# The "--" before the command is required so we don't treat the binary as MB.
# When the limit is exceeded, the process may be killed (SIGKILL) by the OS,
# or the VM may print "Error: heap allocation failed (requested N bytes)" and exit.
#
# Alternative: set CROWN_VM_MAX_MEMORY_MB in the environment (e.g. 256) and run
# the VM directly. The process will set RLIMIT_AS internally; when the limit is
# hit, brk fails and the VM prints the allocation-failure message (with requested
# size) and exits, instead of being SIGKILLed.

set -e
MB=256
if [[ $1 =~ ^[0-9]+$ ]]; then
  MB=$1
  shift
fi
if [[ $1 == "--" ]]; then
  shift
fi
# ulimit -v is in KB on Linux
LIMIT_KB=$((MB * 1024))
ulimit -v "$LIMIT_KB"
exec "$@"
