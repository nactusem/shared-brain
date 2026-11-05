# shellcheck shell=bash
# Sourced by test/run.sh.

ih=$(mktemp -d)
mkdir -p "$ih/.claude"
cat > "$ih/.claude/settings.json" <<'EOF'
{
  "model": "opus",
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "echo mine" } ] }
    ]
  }
}
EOF
echo "# my rules" > "$ih/.claude/CLAUDE.md"
installed_command="SHARED_BRAIN_DIR=$ih/brain bash $ih/.claude/hooks/brain-context.sh"

# Without a terminal and without --yes, nothing in ~/.claude may change.
HOME="$ih" bash "$root/install.sh" < /dev/null > /dev/null
check "asks before touching settings" \
  "1" "$(jq '.hooks.SessionStart | length' "$ih/.claude/settings.json")"
check "asks before touching CLAUDE.md" \
  "# my rules" "$(cat "$ih/.claude/CLAUDE.md")"

check "installs the empty starter brain, not the example" \
  "1 0" "$(grep -c 'Not filled in yet' "$ih/brain/MAP.md") $(grep -c Invoicer "$ih/brain/MAP.md")"

check "starts the brain as a git repo" \
  "yes" "$([ -d "$ih/brain/.git" ] && echo yes)"

check "installs the hook and the limit check" \
  "yes yes" \
  "$([ -f "$ih/.claude/hooks/brain-context.sh" ] && echo yes) $([ -f "$ih/.claude/skills/brain/check-limits.sh" ] && echo yes)"

check "points the skill at the brain" \
  "0 1" \
  "$(grep -c __BRAIN_DIR__ "$ih/.claude/skills/brain/SKILL.md") $(grep -c "^description: Updates the shared brain in $ih/brain " "$ih/.claude/skills/brain/SKILL.md")"

HOME="$ih" bash "$root/install.sh" --yes > /dev/null
check "adds the import line" \
  "@$ih/brain/MAP.md" "$(tail -n 1 "$ih/.claude/CLAUDE.md")"
check "keeps what CLAUDE.md had" \
  "# my rules" "$(head -n 1 "$ih/.claude/CLAUDE.md")"
check "adds the hook next to existing ones" \
  "echo mine|$installed_command" \
  "$(jq -r '[.hooks.SessionStart[].hooks[].command] | join("|")' "$ih/.claude/settings.json")"
check "keeps other settings" \
  "opus" "$(jq -r .model "$ih/.claude/settings.json")"
check "backs up both files" \
  "2" "$(ls "$ih/.claude" | grep -c '\.bak-')"

HOME="$ih" bash "$root/install.sh" --yes > /dev/null
check "a second run adds nothing" \
  "1 2" \
  "$(grep -c "^@$ih/brain/MAP.md$" "$ih/.claude/CLAUDE.md") $(jq '.hooks.SessionStart | length' "$ih/.claude/settings.json")"

echo "my own map" > "$ih/brain/MAP.md"
HOME="$ih" bash "$root/install.sh" --yes > /dev/null
check "never overwrites an existing brain" \
  "my own map" "$(cat "$ih/brain/MAP.md")"

rm -rf "$ih"

# A settings file that is not valid JSON is never rewritten.
ib=$(mktemp -d)
mkdir -p "$ib/.claude"
echo '{ broken' > "$ib/.claude/settings.json"
status=$(HOME="$ib" bash "$root/install.sh" --yes > /dev/null; echo $?)
check "leaves invalid settings alone and fails" \
  "1 { broken" "$status $(cat "$ib/.claude/settings.json")"
rm -rf "$ib"

# A fresh machine without ~/.claude at all.
ic=$(mktemp -d)
HOME="$ic" bash "$root/install.sh" --yes > /dev/null
check "works on a fresh machine" \
  "1 @$ic/brain/MAP.md" \
  "$(jq '.hooks.SessionStart | length' "$ic/.claude/settings.json") $(tail -n 1 "$ic/.claude/CLAUDE.md")"
rm -rf "$ic"
