#!/bin/bash
# Installs shared-brain for the current user.
# Usage: ./install.sh [brain dir]   (default: ~/brain)
#
# Copies the example brain, the hook and the skill, and never overwrites a
# file that is already there. It does not edit your Claude Code settings:
# it prints the two lines to add yourself, so you see every change.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
brain="${1:-$HOME/brain}"
claude="$HOME/.claude"

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

if copy "$here/example-brain" "$brain"; then
  git -C "$brain" init -q
fi
copy "$here/hooks/brain-context.sh" "$claude/hooks/brain-context.sh" || true
if copy "$here/skills/brain" "$claude/skills/brain"; then
  sed -i.orig "s|__BRAIN_DIR__|$brain|g" "$claude/skills/brain/SKILL.md"
  rm "$claude/skills/brain/SKILL.md.orig"
fi

cat <<EOF

Two steps left, both by hand:

1. Add this line to ~/.claude/CLAUDE.md:

   @$brain/MAP.md

2. Add this hook to ~/.claude/settings.json, inside "hooks":

   "SessionStart": [
     {
       "hooks": [
         {
           "type": "command",
           "command": "SHARED_BRAIN_DIR=$brain bash $claude/hooks/brain-context.sh",
           "timeout": 10
         }
       ]
     }
   ]

Then replace the example in $brain with your own projects:
MAP.md for the catalog, map.tsv for which folder loads which group.
EOF
