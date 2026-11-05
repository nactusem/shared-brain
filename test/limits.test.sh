# shellcheck shell=bash
# Sourced by test/run.sh.

limits="$root/skills/brain/check-limits.sh"
lb=$(mktemp -d)
mkdir -p "$lb/groups"

# repeat <char> <count>
repeat() {
  head -c "$2" /dev/zero | tr '\0' "$1"
}

seq 1 100 > "$lb/MAP.md"
repeat a 9000 > "$lb/groups/acme.md"
repeat a 15000 > "$lb/lessons.md"
check "files at their limits pass" \
  "0" "$(bash "$limits" "$lb" > /dev/null; echo $?)"

seq 1 101 > "$lb/MAP.md"
check "a map over 100 lines fails" \
  "over limit: MAP.md has 101 lines, max 100" "$(bash "$limits" "$lb")"
seq 1 100 > "$lb/MAP.md"

repeat a 9001 > "$lb/groups/acme.md"
check "a group brain over 9,000 characters fails" \
  "over limit: groups/acme.md has 9001 characters, max 9000" \
  "$(bash "$limits" "$lb")"
repeat a 9000 > "$lb/groups/acme.md"

repeat a 15001 > "$lb/lessons.md"
check "lessons over 15,000 characters fail" \
  "1" "$(bash "$limits" "$lb" > /dev/null; echo $?)"

check "a missing brain exits 2" \
  "2" "$(bash "$limits" "$lb/missing" > /dev/null; echo $?)"

rm -rf "$lb"
