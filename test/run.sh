#!/bin/bash
# Runs every *.test.sh in this folder. Needs bash, jq and coreutils.
set -u

cd "$(dirname "$0")/.." || exit 1
root=$PWD
passed=0
failed=0

# check <name> <expected> <actual>
check() {
  if [ "$2" = "$3" ]; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
  fi
}

for t in test/*.test.sh; do
  # shellcheck source=/dev/null
  . "$t"
done

echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
