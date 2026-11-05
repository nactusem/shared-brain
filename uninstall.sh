#!/bin/bash
# Removes what install.sh added to Claude Code.
# Usage: ./uninstall.sh [--yes] [brain dir]   (default brain dir: ~/brain)
#
# Takes the import line out of ~/.claude/CLAUDE.md, the hook entry out of
# ~/.claude/settings.json, and deletes the hook script and the skill.
# The brain itself is your data and is never deleted.
set -euo pipefail

yes=0
if [ "${1:-}" = "--yes" ]; then
  yes=1
  shift
fi

brain="${1:-$HOME/brain}"
claude="$HOME/.claude"
memory="$claude/CLAUDE.md"
settings="$claude/settings.json"
import="@$brain/MAP.md"
command="SHARED_BRAIN_DIR=$brain bash $claude/hooks/brain-context.sh"

if ! command -v jq > /dev/null 2>&1; then
  echo "jq is not installed. Remove the SessionStart entry running"
  echo "  $command"
  echo "from $settings by hand, then run this again."
  exit 1
fi

echo "This removes:"
echo "  the line $import from $memory"
echo "  the SessionStart hook for this brain from $settings"
echo "  $claude/hooks/brain-context.sh and $claude/skills/brain"
echo "It keeps $brain."

if [ "$yes" -eq 0 ]; then
  if [ ! -t 0 ]; then
    echo "Run with --yes to remove without asking."
    exit 0
  fi
  printf 'Remove them now? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes) ;;
    *) exit 0 ;;
  esac
fi

stamp=$(date +%Y%m%d%H%M%S)

if grep -qxF "$import" "$memory" 2> /dev/null; then
  cp "$memory" "$memory.bak-$stamp"
  kept=$(grep -vxF "$import" "$memory" || true)
  printf '%s\n' "$kept" > "$memory"
  echo "removed the import from $memory"
fi

if grep -qF "$command" "$settings" 2> /dev/null; then
  cp "$settings" "$settings.bak-$stamp"
  # Drop only this hook. Emptied entries and lists go too, so the file
  # looks the way it did before the install.
  kept=$(jq --arg c "$command" '
    .hooks.SessionStart |= (
      map(.hooks |= map(select(.command != $c)))
      | map(select((.hooks | length) > 0))
    )
    | if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end
    | if .hooks == {} then del(.hooks) else . end
  ' "$settings")
  printf '%s\n' "$kept" > "$settings"
  echo "removed the hook from $settings"
fi

rm -f "$claude/hooks/brain-context.sh"
rm -rf "$claude/skills/brain"

echo "Done. Your brain is still in $brain."
