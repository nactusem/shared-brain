# shellcheck shell=bash
# Sourced by test/run.sh.

uh=$(mktemp -d)
mkdir -p "$uh/.claude"
cat > "$uh/.claude/settings.json" <<'EOF'
{
  "model": "opus",
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "echo mine" } ] }
    ]
  }
}
EOF
echo "# my rules" > "$uh/.claude/CLAUDE.md"
before_settings=$(jq -S . "$uh/.claude/settings.json")

HOME="$uh" bash "$root/install.sh" --yes > /dev/null
echo "a lesson I wrote" >> "$uh/brain/lessons.md"

HOME="$uh" bash "$root/uninstall.sh" < /dev/null > /dev/null
check "asks before removing" \
  "yes" "$([ -d "$uh/.claude/skills/brain" ] && echo yes)"

HOME="$uh" bash "$root/uninstall.sh" --yes > /dev/null
check "restores settings to what they were" \
  "$before_settings" "$(jq -S . "$uh/.claude/settings.json")"
check "restores CLAUDE.md to what it was" \
  "# my rules" "$(cat "$uh/.claude/CLAUDE.md")"
check "removes the hook script and the skill" \
  "no no" \
  "$([ -e "$uh/.claude/hooks/brain-context.sh" ] && echo yes || echo no) $([ -e "$uh/.claude/skills/brain" ] && echo yes || echo no)"
check "keeps the brain" \
  "a lesson I wrote" "$(tail -n 1 "$uh/brain/lessons.md")"

rm -rf "$uh"

# On a machine that had no hooks before, the hooks key goes away again.
ux=$(mktemp -d)
HOME="$ux" bash "$root/install.sh" --yes > /dev/null
HOME="$ux" bash "$root/uninstall.sh" --yes > /dev/null
check "leaves no empty hooks behind" \
  "{}" "$(jq -c . "$ux/.claude/settings.json")"
rm -rf "$ux"
