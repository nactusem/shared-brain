#!/bin/bash
# Claude Code SessionStart hook: prints the group brain whose folder prefix
# matches the session's working directory.
#
# The cwd from the hook input is only ever compared as a string. Any problem
# ends in a silent exit 0, because a broken brain must never block a session.

BRAIN="${SHARED_BRAIN_DIR:-$HOME/brain}"
MAP="$BRAIN/map.tsv"
# Claude Code cuts long hook output, so stay below its limit and say so.
MAX="${SHARED_BRAIN_MAX_CHARS:-9500}"

input=$(cat)
cwd=""
if command -v jq >/dev/null 2>&1; then
  cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
fi
[ -z "$cwd" ] && cwd="$PWD"
[ -f "$MAP" ] || exit 0

best=""
bestlen=0
while IFS=$'\t' read -r prefix file || [ -n "$prefix" ]; do
  case "$prefix" in ''|\#*) continue ;; esac
  prefix="${prefix/#\~/$HOME}"
  prefix="${prefix%/}"
  # Quoting the prefix keeps glob characters in folder names literal.
  if [ "$cwd" = "$prefix" ] || [[ "$cwd" == "$prefix"/* ]]; then
    if [ "${#prefix}" -gt "$bestlen" ]; then
      best="$file"
      bestlen=${#prefix}
    fi
  fi
done < "$MAP"

[ -z "$best" ] && exit 0
# Group files sit directly in groups/. A map entry that looks like a path
# could point anywhere on disk, so it is ignored.
case "$best" in */*|*..*) exit 0 ;; esac
f="$BRAIN/groups/$best"
[ -f "$f" ] || exit 0

echo "Shared brain: group brain for this session ($f). Update it with /brain."
echo
if [ "$(wc -c < "$f")" -le "$MAX" ]; then
  cat "$f"
else
  head -c "$MAX" "$f"
  echo
  echo "[Truncated. Read $f for the rest.]"
fi
exit 0
