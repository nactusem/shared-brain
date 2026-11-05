#!/bin/bash
# Installs shared-brain for the current user.
# Usage: ./install.sh [--yes] [brain dir]   (default brain dir: ~/brain)
#
# Copies an empty starter brain, the hook and the skill, and never
# overwrites a file that is already there. Before it changes
# ~/.claude/CLAUDE.md or ~/.claude/settings.json it shows the change and
# asks, unless --yes is given. Both files are backed up first.
set -euo pipefail

yes=0
if [ "${1:-}" = "--yes" ]; then
  yes=1
  shift
fi

here=$(cd "$(dirname "$0")" && pwd)
brain="${1:-$HOME/brain}"
claude="$HOME/.claude"
memory="$claude/CLAUDE.md"
settings="$claude/settings.json"
import="@$brain/MAP.md"
command="SHARED_BRAIN_DIR=$brain bash $claude/hooks/brain-context.sh"

# copy <source> <target>: returns 1 when the target already exists.
copy() {
  if [ -e "$2" ]; then
    echo "kept   $2 (already there)"
    return 1
  fi
  mkdir -p "$(dirname "$2")"
  cp -R "$1" "$2"
  echo "added  $2"
}

if copy "$here/starter-brain" "$brain"; then
  git -C "$brain" init -q
fi
copy "$here/hooks/brain-context.sh" "$claude/hooks/brain-context.sh" || true
if copy "$here/skills/brain" "$claude/skills/brain"; then
  sed -i.orig "s|__BRAIN_DIR__|$brain|g" "$claude/skills/brain/SKILL.md"
  rm "$claude/skills/brain/SKILL.md.orig"
fi

need_import=1
grep -qxF "$import" "$memory" 2>/dev/null && need_import=0
need_hook=1
grep -qF "$command" "$settings" 2>/dev/null && need_hook=0

if [ "$need_import" -eq 0 ] && [ "$need_hook" -eq 0 ]; then
  echo
  echo "Claude Code already loads this brain. Start a new session to use it."
  exit 0
fi

# Only shown to the user. The real merge below builds the JSON with jq.
hook_json="{ \"hooks\": [ { \"type\": \"command\", \"command\": \"$command\", \"timeout\": 10 } ] }"

by_hand() {
  echo
  echo "Add these by hand:"
  [ "$need_import" -eq 1 ] && printf '\n  %s, a line of its own:\n    %s\n' "$memory" "$import"
  [ "$need_hook" -eq 1 ] && printf '\n  %s, inside "hooks", "SessionStart": [ ... ]:\n    %s\n' "$settings" "$hook_json"
  echo
}

echo
echo "Claude Code needs two changes to load the brain:"
[ "$need_import" -eq 1 ] && echo "  $memory: add the line $import"
[ "$need_hook" -eq 1 ] && echo "  $settings: add a SessionStart hook that runs the brain hook"

if ! command -v jq > /dev/null 2>&1; then
  echo "jq is not installed, so the settings cannot be merged safely."
  by_hand
  exit 0
fi

if [ -f "$settings" ] && ! jq empty "$settings" 2> /dev/null; then
  echo "$settings is not valid JSON, so it was left alone."
  by_hand
  exit 1
fi

if [ "$yes" -eq 0 ]; then
  if [ ! -t 0 ]; then
    by_hand
    exit 0
  fi
  printf 'Make these changes now? A backup of each file is kept next to it. [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes) ;;
    *) by_hand; exit 0 ;;
  esac
fi

stamp=$(date +%Y%m%d%H%M%S)
mkdir -p "$claude"

if [ "$need_import" -eq 1 ]; then
  [ -f "$memory" ] && cp "$memory" "$memory.bak-$stamp"
  printf '\n%s\n' "$import" >> "$memory"
  echo "added  $import to $memory"
fi

if [ "$need_hook" -eq 1 ]; then
  if [ -f "$settings" ]; then
    cp "$settings" "$settings.bak-$stamp"
  else
    echo '{}' > "$settings"
  fi
  merged=$(jq --arg c "$command" \
    '.hooks.SessionStart += [{hooks: [{type: "command", command: $c, timeout: 10}]}]' \
    "$settings")
  # Write through the existing file so a symlinked settings.json stays a symlink.
  printf '%s\n' "$merged" > "$settings"
  echo "added  SessionStart hook to $settings"
fi

echo
echo "Done. Start a new Claude Code session, then type /brain to fill in your map."
