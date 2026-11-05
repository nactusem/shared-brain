#!/bin/bash
# Checks the size limits that keep a brain worth reading.
# Usage: check-limits.sh [brain dir]
# Exits 1 and names every file over its limit, 2 if there is no brain.

BRAIN="${1:-${SHARED_BRAIN_DIR:-$HOME/brain}}"
MAP_MAX_LINES=100
GROUP_MAX_CHARS=9000
LESSONS_MAX_CHARS=15000

[ -d "$BRAIN" ] || { echo "no brain at $BRAIN"; exit 2; }

status=0
over() {
  echo "over limit: $1"
  status=1
}

chars() {
  wc -m < "$1" | tr -d ' '
}

if [ -f "$BRAIN/MAP.md" ]; then
  lines=$(wc -l < "$BRAIN/MAP.md" | tr -d ' ')
  [ "$lines" -le "$MAP_MAX_LINES" ] ||
    over "MAP.md has $lines lines, max $MAP_MAX_LINES"
fi

for f in "$BRAIN"/groups/*.md; do
  [ -f "$f" ] || continue
  n=$(chars "$f")
  [ "$n" -le "$GROUP_MAX_CHARS" ] ||
    over "groups/$(basename "$f") has $n characters, max $GROUP_MAX_CHARS"
done

if [ -f "$BRAIN/lessons.md" ]; then
  n=$(chars "$BRAIN/lessons.md")
  [ "$n" -le "$LESSONS_MAX_CHARS" ] ||
    over "lessons.md has $n characters, max $LESSONS_MAX_CHARS"
fi

exit $status
